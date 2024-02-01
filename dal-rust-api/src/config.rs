#[derive(Debug, Clone)]
pub struct Secrets {
    pub mal_client_id: String,
    pub mal_client_secret: String,
    pub bearer_secret: String,
    pub redis_host_name: String,
    pub redis_password: String,
}

#[derive(Debug, Clone)]
pub struct Config {
    pub base_url: String,
    pub secrets: Secrets,
}

impl Config {
    pub fn init() -> Config {
        let bearer_secret = std::env::var("BEARER_SECRET").expect("BEARER_SECRET must be set");
        let mal_client_secret = std::env::var("MAL_CLIENT_SECRET").expect("missing MAL_CLIENT_SECRET");
        let mal_client_id = std::env::var("MAL_CLIENT_ID").expect("missing MAL_CLIENT_ID");
        let base_url = std::env::var("BASE_URL").expect("missing BASE_URL");
        let redis_host_name = std::env::var("REDIS_HOST_NAME").expect("missing REDIS_HOST_NAME");
        let redis_password = std::env::var("REDIS_PASSWORD").expect("missing REDIS_PASSWORD");
        let secrets = Secrets {
            mal_client_secret,
            mal_client_id,
            bearer_secret,
            redis_host_name,
            redis_password,
        };

        Config { secrets, base_url }
    }
}
