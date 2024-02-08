use serde::{Deserialize, Serialize};

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
    pub alternative_titles: Option<AlternateTitles>
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
    sequel,
    prequel,
    alternative_setting,
    alternative_version,
    side_story,
    parent_story,
    summary,
    full_story,
    spin_off,
    character,
    other,
}
