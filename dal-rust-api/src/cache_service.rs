use crate::{config::Config, model::Anime};
use redis::{JsonAsyncCommands, RedisResult};

#[derive(Debug, Clone)]
pub struct CacheService {
    pub config: Config,
}

impl CacheService {
    async fn get_connection(&self) -> redis::aio::Connection {
        let redis_conn_url = format!(
            "{}://:{}@{}",
            "redis", self.config.secrets.redis_password, self.config.secrets.redis_host_name
        );

        let client = redis::Client::open(redis_conn_url).unwrap();
        return client.get_async_connection().await.unwrap();
    }

    pub async fn get_anime_by_id(&self, id: i64) -> Option<Anime> {
        let mut connection = self.get_connection().await;
        let result: Result<String, redis::RedisError> =
            connection.json_get(format!("anime_{}", id), "$").await;
        match result {
            Ok(json) => {
                let anime: Vec<Anime> = serde_json::from_str(&json).unwrap();
                Some(anime[0].clone())
            }
            Err(_) => None,
        }
    }

    pub async fn set_anime_by_id(&self, id: i64, anime: &Anime) -> Option<()> {
        let mut connection = self.get_connection().await;

        let result: RedisResult<String> = connection
            .json_set(format!("anime_{}", id), "$", anime)
            .await;

        match result {
            Ok(_) => Some(()),
            Err(_) => None,
        }
    }
}
