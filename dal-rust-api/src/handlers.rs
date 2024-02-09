use std::sync::Arc;

use crate::{model_dto::ContentGraphDTO, storage_service::SignedURLResponse, AppState};

use axum::{
    extract::{Path, State},
    Json,
};

// A function to handle GET requests at /anime/{id}/related
pub async fn get_related_anime(
    Path(mal_id): Path<i64>,
    State(data): State<Arc<AppState>>,
) -> Json<ContentGraphDTO> {
    Json(data.anime_service.get_related_anime(mal_id).await.unwrap())
}

// A function to GET downloadURL of images
pub async fn get_image_url(
    Path((image_type, image_id)): Path<(String, String)>,
    State(data): State<Arc<AppState>>,
) -> Json<SignedURLResponse> {
    Json(data.image_service.get_image_url(image_type, image_id).await)
}
