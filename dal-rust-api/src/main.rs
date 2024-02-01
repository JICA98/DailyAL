use config::Config;
use dotenv::dotenv;
use reqwest;

mod anime_service;
mod auth;
mod config;
mod handlers;
mod model;
mod routes;
mod mal_api;
mod model_dto;
mod cache_service;

#[derive(Clone)]
pub struct AppState {
    pub config: Config,
    pub anime_service: anime_service::AnimeService,
}

#[tokio::main]
async fn main() {
    dotenv().ok();

    let config = Config::init();
    let app = routes::setup_app(config).await;

    println!("Server started at http://localhost:8000");
    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
