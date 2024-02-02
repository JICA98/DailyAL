use std::sync::Arc;

use crate::{anime_service, auth, config::Config, handlers, AppState};
use axum::{
    http::{
        header::{ACCEPT, AUTHORIZATION, CONTENT_TYPE},
        HeaderValue, Method,
    },
    middleware,
    routing::get,
    Router,
};
use tower_http::cors::CorsLayer;

pub async fn setup_app(config: Config) -> Router {
    let state = Arc::new(AppState {
        config: config.clone(),
        anime_service: anime_service::AnimeService {
            config: config.clone(),
            mal_api: crate::mal_api::MalAPI {
                config: config.clone(),
            },
            cache_service: crate::cache_service::CacheService {
                config: config.clone(),
            },
        },
    });
    Router::new()
        .route(
            "/anime/:id/related",
            get(handlers::get_related_anime)
                .route_layer(middleware::from_fn_with_state(state.clone(), auth::auth)),
        )
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
