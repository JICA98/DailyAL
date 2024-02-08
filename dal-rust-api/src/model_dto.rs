use std::{
    collections::HashSet,
    hash::{Hash, Hasher},
};

use serde::{Deserialize, Serialize};

use crate::model::Anime;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContentGraphDTO {
    pub nodes: HashSet<ContentNodeDTO>,
    pub edges: Vec<EdgeDTO>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ContentNodeDTO {
    pub id: i64,
    pub title: String,
    pub main_picture: Option<MainPictureDTO>,
    pub mean: Option<f64>,
    pub media_type: Option<String>,
    pub status: Option<String>,
    pub start_season: Option<SeasonDTO>,
    pub alternative_titles: Option<AlternateTitlesDTO>,
}

impl Eq for ContentNodeDTO {}

impl PartialEq for ContentNodeDTO {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

impl Hash for ContentNodeDTO {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl From<Anime> for ContentNodeDTO {
    fn from(anime: Anime) -> Self {
        ContentNodeDTO {
            id: anime.id,
            title: anime.title,
            main_picture: anime.main_picture.map(|main_picture| main_picture.into()),
            mean: anime.mean,
            media_type: anime.media_type,
            status: anime.status,
            start_season: anime.start_season.map(|season| season.into()),
            alternative_titles: anime.alternative_titles.map(|alternate_titles| alternate_titles.into()),
        }
    }
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlternateTitlesDTO {
    pub en: Option<String>,
    pub ja: Option<String>,
}

impl From<crate::model::AlternateTitles> for AlternateTitlesDTO {
    fn from(alternate_titles: crate::model::AlternateTitles) -> Self {
        AlternateTitlesDTO {
            en: alternate_titles.en,
            ja: alternate_titles.ja,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EdgeDTO {
    pub source: i64,
    pub target: i64,
    pub relation_type: RelationTypeDTO,
}

impl From<crate::model::Edge> for EdgeDTO {
    fn from(edge: crate::model::Edge) -> Self {
        EdgeDTO {
            source: edge.source,
            target: edge.target,
            relation_type: edge.relation_type.into(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct MainPictureDTO {
    pub medium: String,
    pub large: String,
}

impl From<crate::model::MainPicture> for MainPictureDTO {
    fn from(main_picture: crate::model::MainPicture) -> Self {
        MainPictureDTO {
            medium: main_picture.medium,
            large: main_picture.large,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonDTO {
    pub year: i64,
    pub season: String,
}

impl From<crate::model::Season> for SeasonDTO {
    fn from(season: crate::model::Season) -> Self {
        SeasonDTO {
            year: season.year,
            season: season.season,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum RelationTypeDTO {
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

impl From<crate::model::RelationType> for RelationTypeDTO {
    fn from(relation_type: crate::model::RelationType) -> Self {
        match relation_type {
            crate::model::RelationType::sequel => RelationTypeDTO::sequel,
            crate::model::RelationType::prequel => RelationTypeDTO::prequel,
            crate::model::RelationType::alternative_setting => RelationTypeDTO::alternative_setting,
            crate::model::RelationType::alternative_version => RelationTypeDTO::alternative_version,
            crate::model::RelationType::side_story => RelationTypeDTO::side_story,
            crate::model::RelationType::parent_story => RelationTypeDTO::parent_story,
            crate::model::RelationType::summary => RelationTypeDTO::summary,
            crate::model::RelationType::full_story => RelationTypeDTO::full_story,
            crate::model::RelationType::spin_off => RelationTypeDTO::spin_off,
            crate::model::RelationType::character => RelationTypeDTO::character,
            crate::model::RelationType::other => RelationTypeDTO::other,
        }
    }
}
