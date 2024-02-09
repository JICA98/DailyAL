use core::panic;
use std::sync::Arc;

use crate::{file_storage_service::SignedURLResponse, model_dto::ContentGraphDTO, AppState};

use axum::{
    extract::{Multipart, Path, State},
    Json,
};

/// A function to handle GET requests at /anime/{id}/related
pub async fn get_related_anime(
    Path(mal_id): Path<i64>,
    State(data): State<Arc<AppState>>,
) -> Json<ContentGraphDTO> {
    Json(data.anime_service.get_related_anime(mal_id).await.unwrap())
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
    let mut bytes: Vec<u8> = field.bytes().await.unwrap().into();
    data.image_service
        .save_image(image_type, image_id, &mut bytes)
        .await;
    "ok".to_string()
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
