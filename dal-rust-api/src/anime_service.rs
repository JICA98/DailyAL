use seahash::SeaHasher;
use std::collections::{HashMap, HashSet};
use std::error::Error;
use std::hash::Hasher;
use std::sync::{Arc, Mutex};

use crate::model::{
    Anime, AnimeLink, AnimeQuery, Edge, RelatedAnime, RelationType, ReviewResponse,
    ReviewResponseData,
};

use crate::config::Config;
use crate::model_dto::{ContentGraphDTO, ContentNodeDTO};
use async_recursion::async_recursion;
use chrono::{DateTime, Utc};
use futures::{stream, StreamExt};

const REVIEW_SYSTEM: &str = "You are an anime/manga review critic, you are given the task to go through all the user reviews and provide a review under 500 words. Pros/Cons are optional but atleast one should be present and 3 at max along with a final verdict. Don't hallucinate and don't contradict yourself in pros/cons. Output should be in the format { data: { pros: [ { title, description }, cons: [ { title, description }  ], verdict } }";

pub struct AnimeService {
    pub config: Config,
    pub mal_api: crate::mal_api::MalAPI,
    pub cache_service: crate::cache_service::CacheService,
    pub ai_service: crate::llm_client::LLMClient,
    pub anime_link_service: crate::anime_link_service::AnimeLinkService,
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

    fn get_unvisited_edges(
        &self,
        id: i64,
        related_anime: Option<Vec<RelatedAnime>>,
        include_others: bool,
    ) -> Vec<Edge> {
        let mut unvisited_edges: Vec<Edge> = Vec::new();
        if related_anime.is_some() {
            unvisited_edges.extend(
                related_anime
                    .unwrap()
                    .iter()
                    .filter(|related_anime| {
                        self.valid_relation(&related_anime.relation_type, include_others)
                    })
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
            RelationType::AlternativeSetting => true,
            RelationType::Sequel => true,
            RelationType::Prequel => true,
            RelationType::AlternativeVersion => true,
            RelationType::SideStory => true,
            RelationType::ParentStory => true,
            RelationType::Summary => true,
            RelationType::FullStory => true,
            RelationType::SpinOff => true,
            RelationType::Character => false,
            RelationType::Other => include_others,
        }
    }

    async fn get_anime_by_id(&self, id: i64, from_cache: bool) -> Result<Anime, Box<dyn Error>> {
        let now = chrono::Utc::now();
        let result = match from_cache {
            true => {
                self.cache_service
                    .get_cache_by_id("anime", id.to_string())
                    .await
            }
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
            self.cache_service
                .set_cache_by_id("anime", id.to_string(), &anime, None)
                .await;
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

    pub fn hash_str(&self, s: &str) -> String {
        let mut hasher = SeaHasher::new();
        hasher.write(s.as_bytes());
        let finish = hasher.finish();
        format!("{:x}", finish)
    }

    pub async fn summarize_review(
        &self,
        reviews: &str,
    ) -> Result<ReviewResponse, Box<dyn Error + Send + Sync>> {
        println!("Summarizing review {}", reviews.len());

        let hash_str = self.hash_str(reviews);

        println!("Using hash_key: {}", hash_str);

        let cached_review: Option<ReviewResponse> = self
            .cache_service
            .get_cache_by_id("reviews", hash_str.clone())
            .await;

        if cached_review.is_some() {
            return Ok(cached_review.unwrap());
        } else {
            println!("Cache miss for {}", hash_str);
            let json_str = self.ai_service.talk(REVIEW_SYSTEM, reviews).await?;
            let review_response_data: ReviewResponseData = serde_json::from_str(&json_str)?;

            let review_response = review_response_data.data.clone();

            self.cache_service
                .set_cache_by_id("reviews", hash_str, &review_response, Some(3600 * 24 * 30))
                .await;
            return Ok(review_response);
        }
    }

    pub async fn get_anime(&self, query: AnimeQuery) -> Vec<HashMap<String, String>> {
        let link: Vec<AnimeLink>;
        if query.query.is_some() {
            link = self.get_anime_by_query(&query).await;
        } else if query.mal_id.is_some() {
            link = self.get_anime_by_mal_id(&query).await;
        } else {
            link = self.get_all_anime().await;
        }
        create_map_using_fields(link, &query.fields)
    }

    async fn get_all_anime(&self) -> Vec<AnimeLink> {
        self.anime_link_service.get_all_anime().await
    }

    async fn get_anime_by_mal_id(&self, query: &AnimeQuery) -> Vec<AnimeLink> {
        let mal_id = &query.mal_id.clone().unwrap().clone();
        let anime_link: AnimeLink = self.anime_link_service.get_link_by_id(mal_id).await;
        return Vec::from([anime_link]);
    }

    async fn get_anime_by_query(&self, query: &AnimeQuery) -> Vec<AnimeLink> {
        self.anime_link_service.search(query).await
    }
}

fn create_map_using_fields(
    link: Vec<AnimeLink>,
    fields: &Vec<String>,
) -> Vec<HashMap<String, String>> {
    let mut map: Vec<HashMap<String, String>> = Vec::new();
    for anime in &link {
        let mut hash_map: HashMap<String, String> = HashMap::new();
        for field in fields.iter() {
            match field.as_str() {
                "title" => {
                    if anime.title.is_some() {
                        hash_map
                            .insert("title".to_string(), anime.title.clone().unwrap_or_default());
                    }
                }
                "malId" => {
                    if anime.mal_id.is_some() {
                        hash_map.insert(
                            "malId".to_string(),
                            anime.mal_id.clone().unwrap_or_default(),
                        );
                    }
                }
                "anilistId" => {
                    if anime.anilist_id.is_some() {
                        hash_map.insert(
                            "anilistId".to_string(),
                            anime.anilist_id.clone().unwrap_or_default(),
                        );
                    }
                }
                "kitsuId" => {
                    if anime.kitsu_id.is_some() {
                        hash_map.insert(
                            "kitsuId".to_string(),
                            anime.kitsu_id.clone().unwrap_or_default(),
                        );
                    }
                }
                "animePlanet" => {
                    if anime.anime_planet.is_some() {
                        hash_map.insert(
                            "animePlanet".to_string(),
                            anime.anime_planet.clone().unwrap_or_default(),
                        );
                    }
                }
                "picture" => {
                    if anime.picture.is_some() {
                        hash_map.insert(
                            "picture".to_string(),
                            anime.picture.clone().unwrap_or_default(),
                        );
                    }
                }
                "synonyms" => {
                    if anime.synonyms.is_some() {
                        hash_map.insert(
                            "synonyms".to_string(),
                            anime
                                .synonyms
                                .clone()
                                .unwrap_or_default()
                                .join(",")
                                .to_string(),
                        );
                    }
                }
                "year" => {
                    if anime.year.is_some() {
                        hash_map.insert("year".to_string(), anime.year.clone().unwrap_or_default());
                    }
                }
                "mean" => {
                    hash_map.insert("mean".to_string(), anime.mean.to_string());
                }
                _ => {}
            }
        }
        map.push(hash_map);
    }
    map
}
