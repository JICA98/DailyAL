use std::sync::Arc;

use crate::{
    anime_link_service::{self},
    anime_service, auth,
    cache_service::CacheService,
    config::Config,
    file_storage_service::FileStorageService,
    handlers, image_service,
    mal_api::MalAPI,
    AppState,
};
use axum::{
    http::{
        header::{ACCEPT, AUTHORIZATION, CONTENT_TYPE},
        HeaderValue, Method,
    },
    middleware,
    routing::{delete, get, post},
    Router,
};
use futures::lock::Mutex;
use tower_http::cors::CorsLayer;

pub async fn setup_app(config: Config) -> Router {
    let cache_service = CacheService {
        config: config.clone(),
    };
    cache_service.check_aws_get_item().await;
    let mal_api = MalAPI {
        config: config.clone(),
    };
    let image_service = image_service::ImageService {
        storage_service: FileStorageService {
            config: config.clone(),
        },
        cache_service: cache_service.clone(),
    };
    let anime_link_service = anime_link_service::AnimeLinkService {
        config: config.clone(),
        link_map: Arc::new(Mutex::new(std::collections::HashMap::new())),
    };
    let _ = &anime_link_service.setup_links().await;
    let state = Arc::new(AppState {
        config: config.clone(),
        image_service,
        anime_service: anime_service::AnimeService {
            config: config.clone(),
            mal_api,
            anime_link_service,
            cache_service,
            ai_service: crate::llm_client::LLMClient {
                config: config.clone(),
            },
        },
    });
    Router::new()
        .route("/anime", get(handlers::get_anime))
        .route("/anime/{id}/related", get(handlers::get_related_anime))
        .route(
            "/types/{image_type}/images/{image_id}",
            get(handlers::get_image_url),
        )
        .route(
            "/types/{image_type}/images/{image_id}",
            post(handlers::save_image),
        )
        .route(
            "/types/{image_type}/images/{image_id}",
            delete(handlers::delete_image),
        )
        .route("/schedules", post(handlers::start_schedules))
        .route("/reviews", post(handlers::get_review_summary))
        .route_layer(middleware::from_fn_with_state(state.clone(), auth::auth))
        .with_state(state)
        .layer(get_cors_layer())
}

fn get_cors_layer() -> CorsLayer {
    let cors = CorsLayer::new()
        .allow_origin("http://localhost:3000".parse::<HeaderValue>().unwrap())
        .allow_methods([Method::GET, Method::POST, Method::PATCH, Method::DELETE])
        .allow_credentials(true)
        .allow_headers([AUTHORIZATION, ACCEPT, CONTENT_TYPE]);
    return cors;
}
