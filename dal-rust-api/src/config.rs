#[derive(Debug, Clone)]
pub struct Secrets {
    pub mal_client_id: String,
    pub bearer_secret: String,
    pub rediscloud_url: String,
}

#[derive(Debug, Clone)]
pub struct Config {
    pub base_url: String,
    pub secrets: Secrets,
}

impl Config {
    pub fn init() -> Config {
        let bearer_secret = std::env::var("BEARER_SECRET").expect("BEARER_SECRET must be set");
        let mal_client_id = std::env::var("MAL_CLIENT_ID").expect("missing MAL_CLIENT_ID");
        let base_url = std::env::var("BASE_URL").expect("missing BASE_URL");
        let rediscloud_url = std::env::var("REDISCLOUD_URL").expect("missing REDISCLOUD_URL");
        let secrets = Secrets {
            mal_client_id,
            bearer_secret,
            rediscloud_url
        };

        Config { secrets, base_url }
    }
}
