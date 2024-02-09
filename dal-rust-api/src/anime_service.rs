use std::collections::HashSet;
use std::error::Error;
use std::sync::{Arc, Mutex};

use crate::model::{Anime, Edge, RelatedAnime, RelationType};

use crate::config::Config;
use crate::model_dto::{ContentGraphDTO, ContentNodeDTO};
use async_recursion::async_recursion;
use chrono::{DateTime, Utc};
use futures::{stream, StreamExt};

pub struct AnimeService {
    pub config: Config,
    pub mal_api: crate::mal_api::MalAPI,
    pub cache_service: crate::cache_service::CacheService,
}

impl AnimeService {
    pub async fn get_related_anime(&self, id: i64) -> Result<ContentGraphDTO, Box<dyn Error>> {
        let mut graph = ContentGraphDTO {
            nodes: HashSet::new(),
            edges: Vec::new(),
        };
        self.get_related_anime_with_graph(id, &mut graph, false, true)
            .await?;
        return Ok(graph);
    }

    #[async_recursion]
    pub async fn get_related_anime_with_graph(
        &self,
        id: i64,
        graph: &mut ContentGraphDTO,
        from_cache: bool,
        include_others: bool,
    ) -> Result<(), Box<dyn Error>> {
        let anime = self.get_anime_by_id(id, from_cache).await.unwrap();
        graph.nodes.insert(anime.clone().into());

        let unvisited_edges = self.filter_by_nodes(
            self.get_unvisited_edges(id, anime.related_anime.clone(), include_others),
            &graph.nodes,
        );

        let combined_edges: Arc<Mutex<Vec<Edge>>> = Arc::new(Mutex::new(Vec::new()));
        let combined_anime: Arc<Mutex<Vec<ContentNodeDTO>>> = Arc::new(Mutex::new(Vec::new()));

        stream::iter(unvisited_edges.clone())
            .for_each_concurrent(5, |edge| {
                let combined_edges = Arc::clone(&combined_edges);
                let combined_anime = Arc::clone(&combined_anime);
                async move {
                    let (anime, edges_from_id) = self.get_edges_from_id(edge.target).await;
                    let mut combined_edges = combined_edges.lock().unwrap();
                    combined_edges.extend(edges_from_id);
                    combined_anime.lock().unwrap().push(anime.clone().into());
                }
            })
            .await;

        graph
            .edges
            .extend(unvisited_edges.iter().map(|e| e.clone().into()));
        graph
            .nodes
            .extend(combined_anime.lock().unwrap().clone().into_iter());
        let filter_by_nodes =
            self.filter_by_nodes(combined_edges.lock().unwrap().clone(), &graph.nodes);

        for edge in filter_by_nodes.iter() {
            graph.edges.push(edge.clone().into());
            let _ = self
                .get_related_anime_with_graph(edge.target, graph, true, false)
                .await;
        }
        return Ok(());
    }

    async fn get_edges_from_id(&self, id: i64) -> (Anime, Vec<Edge>) {
        let anime = self.get_anime_by_id(id, true).await.unwrap();
        let vec = anime.related_anime.clone();
        (anime, self.get_unvisited_edges(id, vec, false))
    }

    fn get_unvisited_edges(&self, id: i64, related_anime: Option<Vec<RelatedAnime>>, include_others: bool) -> Vec<Edge> {
        let mut unvisited_edges: Vec<Edge> = Vec::new();
        if related_anime.is_some() {
            unvisited_edges.extend(
                related_anime
                    .unwrap()
                    .iter()
                    .filter(|related_anime| self.valid_relation(&related_anime.relation_type, include_others))
                    .map(|related_anime| Edge {
                        source: id,
                        target: related_anime.node.id,
                        relation_type: related_anime.relation_type.clone(),
                    })
                    .collect::<Vec<Edge>>(),
            );
        }
        unvisited_edges
    }

    fn filter_by_nodes(&self, edges: Vec<Edge>, nodes: &HashSet<ContentNodeDTO>) -> Vec<Edge> {
        edges
            .iter()
            .filter(|edge| {
                !nodes.contains(&ContentNodeDTO {
                    id: edge.target,
                    ..Default::default()
                })
            })
            .map(|e| e.clone())
            .collect()
    }

    fn valid_relation(&self, relation_type: &RelationType, include_others: bool) -> bool {
        match relation_type {
            RelationType::alternative_setting => true,
            RelationType::sequel => true,
            RelationType::prequel => true,
            RelationType::alternative_version => true,
            RelationType::side_story => true,
            RelationType::parent_story => true,
            RelationType::summary => true,
            RelationType::full_story => true,
            RelationType::spin_off => true,
            RelationType::character => false,
            RelationType::other => include_others,
        }
    }

    async fn get_anime_by_id(&self, id: i64, from_cache: bool) -> Result<Anime, Box<dyn Error>> {
        let now = chrono::Utc::now();
        let result = match from_cache {
            true => self.cache_service.get_by_id("anime", id.to_string()).await,
            false => None,
        };

        if result.is_none() {
            println!(
                "{}: Cache miss anime: {}",
                now.format("%d/%m/%Y %H:%M:%S"),
                id
            );
            // If the anime is not in the cache, get it from the MAL API
            let anime = self.mal_api.get_anime_details(id).await?;

            // Store the anime in the cache for future use
            self.cache_service.set_by_id("anime", id.to_string(), &anime, None).await;
            let then = chrono::Utc::now();
            self.log_anime(&anime, "Saved".to_string(), then, now);
            Ok(anime)
        } else {
            let anime = result.unwrap();
            let then = chrono::Utc::now();
            self.log_anime(&anime, "Cache hit".to_string(), then, now);
            Ok(anime)
        }
    }

    fn log_anime(
        &self,
        anime: &Anime,
        hit_or_miss: String,
        then: DateTime<Utc>,
        now: DateTime<Utc>,
    ) {
        println!(
            "{}: {} anime: {} and {} in {}ms",
            then.format("%d/%m/%Y %H:%M:%S"),
            hit_or_miss,
            anime.id,
            anime.title,
            then.timestamp_millis() - now.timestamp_millis()
        );
    }
}
