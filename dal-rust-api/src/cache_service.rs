use crate::config::Config;
use redis::{AsyncCommands, JsonAsyncCommands, RedisResult};
use serde::{de::DeserializeOwned, Serialize};

#[derive(Debug, Clone)]
pub struct CacheService {
    pub config: Config,
}

impl CacheService {
    async fn get_connection(&self) -> redis::aio::Connection {
        let client = redis::Client::open(self.config.secrets.rediscloud_url.to_string()).unwrap();
        return client.get_async_connection().await.unwrap();
    }

    pub async fn get_by_id<T: DeserializeOwned + Clone>(
        &self,
        content_type: &str,
        id: String,
    ) -> Option<T> {
        let mut connection = self.get_connection().await;
        let result: Result<String, redis::RedisError> = connection
            .json_get(format!("{}_{}", content_type, id), "$")
            .await;
        match result {
            Ok(json) => {
                let anime: Vec<T> = serde_json::from_str(&json).unwrap();
                Some(anime[0].clone())
            }
            Err(_) => None,
        }
    }

    pub async fn set_by_id<T: Serialize + std::marker::Sync + std::marker::Send>(
        &self,
        content_type: &str,
        id: String,
        anime: &T,
        expiry: Option<i64>,
    ) -> Option<()> {
        let mut connection = self.get_connection().await;

        let key = format!("{}_{}", content_type, id);
        let result: RedisResult<String> = connection.json_set(key.clone(), "$", anime).await;

        if expiry.is_some() {
            let _: RedisResult<String> = connection.expire(key, expiry.unwrap()).await;
        }

        match result {
            Ok(_) => Some(()),
            Err(_) => None,
        }
    }

    pub async fn delete_by_id(&self, content_type: &str, id: String) {
        let mut connection = self.get_connection().await;
        let _: RedisResult<String> = connection.del(format!("{}_{}", content_type, id)).await;
    }
}
