use core::panic;
use std::{collections::HashMap, sync::Arc};

use crate::{
    file_storage_service::SignedURLResponse,
    model::{AnimeQuery, File, ReviewResponse},
    model_dto::ContentGraphDTO,
    AppState,
};

use axum::{
    extract::{Multipart, Path, State},
    http::{HeaderMap, StatusCode},
    Json,
};
use serde_json::{json, Value};

/// A function to handle GET requests at /anime/{id}/related
pub async fn get_related_anime(
    Path(mal_id): Path<i64>,
    State(data): State<Arc<AppState>>,
) -> Json<ContentGraphDTO> {
    Json(data.anime_service.get_related_anime(mal_id).await.unwrap())
}

/// A function to handle GET requests at /anime
pub async fn get_anime(
    headers: HeaderMap,
    State(data): State<Arc<AppState>>,
) -> Json<Vec<HashMap<String, String>>> {
    let anime_query = AnimeQuery::from_headers(headers);
    Json(data.anime_service.get_anime(anime_query).await)
}

/// A function to GET downloadURL of images
pub async fn get_image_url(
    Path((image_type, image_id)): Path<(String, String)>,
    State(data): State<Arc<AppState>>,
) -> Json<SignedURLResponse> {
    Json(data.image_service.get_image_url(image_type, image_id).await)
}

pub async fn save_image(
    State(data): State<Arc<AppState>>,
    Path((image_type, image_id)): Path<(String, String)>,
    mut multipart: Multipart,
) -> String {
    let field = multipart.next_field().await.unwrap().unwrap();
    validate_field("image", &field);
    let file = field_to_file(field).await;
    data.image_service
        .save_image(image_type, image_id, file)
        .await;
    "ok".to_string()
}

pub async fn delete_image(
    State(data): State<Arc<AppState>>,
    Path((image_type, image_id)): Path<(String, String)>,
) -> String {
    data.image_service.delete_image(image_type, image_id).await;
    "ok".to_string()
}

pub async fn get_review_summary(
    State(data): State<Arc<AppState>>,
    body: String,
) -> Result<Json<ReviewResponse>, (StatusCode, String)> {
    match data.anime_service.summarize_review(body.as_str()).await {
        Ok(response) => Ok(Json(response)),
        Err(e) => {
            println!("Error in get_review_summary: {:?}", e);
            Err((StatusCode::INTERNAL_SERVER_ERROR, format!("{:?}", e)))
        }
    }
}

pub async fn start_schedules(State(data): State<Arc<AppState>>) -> Json<Value> {
    data.anime_service.anime_link_service.setup_links().await;
    Json(json!({"status": "ok"}))
}

async fn field_to_file(field: axum::extract::multipart::Field<'_>) -> File {
    let content_type = field.content_type().unwrap().to_string();
    let file_name = field.file_name().unwrap().to_string();
    let content: Vec<u8> = field.bytes().await.unwrap().into();
    File {
        content,
        content_type,
        file_name,
    }
}

fn validate_field(field_name: &str, field: &axum::extract::multipart::Field<'_>) {
    match field.name() {
        Some(name) => {
            if name != field_name {
                panic!("Invalid field name");
            }
        }
        None => panic!("Invalid field name"),
    }
}
