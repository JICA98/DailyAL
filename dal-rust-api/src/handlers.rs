use std::sync::Arc;

use crate::{model_dto::ContentGraphDTO, AppState};

use axum::{extract::{Path, State}, Json};

// A function to handle GET requests at /anime/{id}/related
pub async fn get_related_anime(
    Path(mal_id): Path<i64>,
    State(data): State<Arc<AppState>>,
) -> Json<ContentGraphDTO> {
    Json(data.anime_service.get_related_anime(mal_id).await.unwrap())
}
