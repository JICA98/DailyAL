use std::collections::HashMap;

use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Anime {
    pub id: i64,
    pub title: String,
    pub main_picture: Option<MainPicture>,
    pub mean: Option<f64>,
    pub media_type: Option<String>,
    pub status: Option<String>,
    pub start_season: Option<Season>,
    pub related_anime: Option<Vec<RelatedAnime>>,
    pub alternative_titles: Option<AlternateTitles>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlternateTitles {
    pub en: Option<String>,
    pub ja: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MainPicture {
    pub medium: String,
    pub large: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RelatedAnime {
    pub node: Node,
    pub relation_type: RelationType,
    pub relation_type_formatted: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Node {
    pub id: i64,
    pub title: String,
    pub main_picture: MainPicture,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Season {
    pub year: i64,
    pub season: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Edge {
    pub source: i64,
    pub target: i64,
    pub relation_type: RelationType,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum RelationType {
    #[serde(rename = "sequel")]
    Sequel,
    #[serde(rename = "prequel")]
    Prequel,
    #[serde(rename = "alternative_setting")]
    AlternativeSetting,
    #[serde(rename = "alternative_version")]
    AlternativeVersion,
    #[serde(rename = "side_story")]
    SideStory,
    #[serde(rename = "parent_story")]
    ParentStory,
    #[serde(rename = "summary")]
    Summary,
    #[serde(rename = "full_story")]
    FullStory,
    #[serde(rename = "spin_off")]
    SpinOff,
    #[serde(rename = "character")]
    Character,
    #[serde(rename = "other")]
    Other,
}

#[derive(Debug, Clone)]
pub struct AnimeQuery {
    pub mal_id: Option<String>,
    pub query: Option<String>,
    pub size: Option<usize>,
    pub page: Option<usize>,
    pub fields: Vec<String>,
}
impl AnimeQuery {
    pub fn from_headers(headers: axum::http::HeaderMap) -> AnimeQuery {
        AnimeQuery {
            mal_id: headers
                .get("mal_id")
                .map(|v| v.to_str().unwrap().to_string()),
            query: headers
                .get("query")
                .map(|v| v.to_str().unwrap().to_string()),
            size: headers
                .get("size")
                .map(|v| v.to_str().unwrap().parse().unwrap()),
            page: headers
                .get("page")
                .map(|v| v.to_str().unwrap().parse().unwrap()),
            fields: extract_fields(headers).unwrap_or(default_fields()),
        }
    }
}

fn default_fields() -> Vec<String> {
    vec![
        "title".to_string(),
        "picture".to_string(),
        "year".to_string(),
        "synonyms".to_string(),
        "malId".to_string(),
        "anilistId".to_string(),
        "kitsuId".to_string(),
        "animePlanet".to_string(),
        "mean".to_string(),
    ]
}

fn extract_fields(headers: axum::http::HeaderMap) -> Option<Vec<String>> {
    headers.get("fields").map(|v| {
        v.to_str()
            .unwrap()
            .split(",")
            .map(|s| s.to_string().trim().to_string())
            .collect()
    })
}

pub struct File {
    pub content: Vec<u8>,
    pub content_type: String,
    pub file_name: String,
}

#[derive(Clone, Deserialize, Serialize, Debug)]
pub struct ReviewResponse {
    pros: Vec<ReviewItem>,
    cons: Vec<ReviewItem>,
    verdict: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReviewResponseData {
    pub data: ReviewResponse,
}

#[derive(Clone, Deserialize, Serialize, Debug)]
pub struct ReviewItem {
    title: String,
    description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnimeLink {
    pub title: Option<String>,
    pub picture: Option<String>,
    pub year: Option<String>,
    pub synonyms: Option<Vec<String>>,
    pub mean: f64,
    #[serde(rename(serialize = "malId", deserialize = "malId"))]
    pub mal_id: Option<String>,
    #[serde(rename(serialize = "anilistId", deserialize = "anilistId"))]
    pub anilist_id: Option<String>,
    #[serde(rename(serialize = "kitsuId", deserialize = "kitsuId"))]
    pub kitsu_id: Option<String>,
    #[serde(rename(serialize = "animePlanet", deserialize = "animePlanet"))]
    pub anime_planet: Option<String>,
}

impl From<HashMap<String, String>> for AnimeLink {
    fn from(map: HashMap<String, String>) -> AnimeLink {
        AnimeLink {
            title: map.get("title").cloned(),
            mal_id: map.get("malId").cloned(),
            anilist_id: map.get("anilistId").cloned(),
            kitsu_id: map.get("kitsuId").cloned(),
            anime_planet: map.get("animePlanet").cloned(),
            mean: 0.0,
            picture: None,
            year: None,
            synonyms: None,
        }
    }
}

impl From<Value> for AnimeLink {
    fn from(anime: Value) -> AnimeLink {
        let sources_opt = anime.get("sources").unwrap().as_array();
        let sources = sources_opt.unwrap();
        let map: HashMap<String, String> = sources
            .iter()
            .filter_map(|source| {
                source
                    .as_str()
                    .map(|link| parse_link(link.to_string()))
                    .flatten()
            })
            .collect();
        let mut anime_link: AnimeLink = map.into();
        let title = anime.get("title").map(|f| f.as_str()).flatten();
        let picture = anime.get("picture").map(|f| f.as_str()).flatten();
        anime_link.synonyms = get_synonyms(&anime);
        anime_link.title = title.map(|f| f.to_string());
        anime_link.picture = picture.map(|f| f.to_string());
        anime_link.year = get_year(&anime);
        anime_link.mean = get_score(&anime);
        anime_link
    }
}

fn parse_link(link: String) -> Option<(String, String)> {
    let parts: Vec<&str> = link.split("/").collect();
    let id = parts.last().unwrap_or(&"").to_string();
    if id.is_empty() {
        return None;
    }
    if link.contains("myanimelist") {
        return Some(("malId".to_string(), id));
    } else if link.contains("anilist") {
        return Some(("anilistId".to_string(), id));
    } else if link.contains("kitsu") {
        return Some(("kitsuId".to_string(), id));
    } else if link.contains("anime-planet") {
        return Some(("animePlanet".to_string(), id));
    }
    return None;
}

fn get_synonyms(anime: &Value) -> Option<Vec<String>> {
    let mut synonyms: Option<Vec<String>> = Option::None;
    anime
        .get("synonyms")
        .map(|f| f.as_array())
        .flatten()
        .map(|f| {
            synonyms = Some(
                f.iter()
                    .filter_map(|f| f.as_str())
                    .map(|f| f.to_string())
                    .collect(),
            )
        });
    synonyms
}

fn get_year(anime: &Value) -> Option<String> {
    anime
        .get("animeSeason")
        .map(|f| f.as_object())
        .flatten()
        .map(|f| f.get("year"))
        .flatten()
        .map(|f| f.as_str())
        .flatten()
        .map(|f| f.to_string())
}

fn get_score(anime: &Value) -> f64 {
    anime
        .get("score")
        .map(|f| f.as_object())
        .flatten()
        .map(|f| f.get("median"))
        .flatten()
        .map(|f| f.to_string())
        .map(|f| f.parse::<f64>().unwrap())
        .or_else(|| Some(0.0))
        .unwrap_or(0.0)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OpenAIResponse {
    pub id: Option<String>,
    pub object: Option<String>,
    pub created: Option<i64>,
    pub model: Option<String>,
    pub choices: Vec<Choice>,
    pub usage: Option<Usage>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Choice {
    pub index: i64,
    pub message: Message,
    pub finish_reason: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Message {
    pub role: String,
    pub content: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Usage {
    pub prompt_tokens: i64,
    pub completion_tokens: i64,
    pub total_tokens: i64,
}
