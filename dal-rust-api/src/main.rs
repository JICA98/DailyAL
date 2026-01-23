use config::Config;
use dotenv::dotenv;
use reqwest;
use scheduler_service::run_schedulers;

mod anime_link_service;
mod anime_service;
mod auth;
mod cache_service;
mod config;
mod file_storage_service;
mod handlers;
mod image_service;
mod llm_client;
mod mal_api;
mod model;
mod model_dto;
mod routes;
mod scheduler_service;

pub struct AppState {
    pub config: Config,
    pub image_service: image_service::ImageService,
    pub anime_service: anime_service::AnimeService,
}

#[tokio::main]
async fn main() {
    dotenv().ok();

    let config = Config::init().await;
    let app = routes::setup_app(config.clone()).await;

    let port = std::env::var("PORT").unwrap_or_else(|_| "8001".to_string());
    let addr = format!("0.0.0.0:{}", port);
    println!("Server started at http://{}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    run_schedulers().await;
    axum::serve(listener, app).await.unwrap();
}
