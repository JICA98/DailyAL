use aws_config::{meta::region::RegionProviderChain, Region};

#[derive(Debug, Clone)]
pub struct Secrets {
    pub mal_client_id: String,
    pub bearer_secret: String,
    pub rediscloud_url: String,
    pub subastorage_url: String,
    pub subastorage_key: String,
    pub dynamo_db: aws_sdk_dynamodb::Client,
    pub table_name: String,
    pub ai_api_url: String,
    pub anime_db_url: String,
    pub llm_api_key: String,
    pub llm_model_name: String,
    pub llm_api_url: String,
}

#[derive(Debug, Clone)]
pub struct Config {
    pub base_url: String,
    pub secrets: Secrets,
}

impl Config {
    pub async fn init() -> Config {
        let bearer_secret = std::env::var("BEARER_SECRET").expect("BEARER_SECRET must be set");
        let mal_client_id = std::env::var("MAL_CLIENT_ID").expect("missing MAL_CLIENT_ID");
        let base_url = std::env::var("BASE_URL").expect("missing BASE_URL");
        let rediscloud_url = std::env::var("REDISCLOUD_URL").expect("missing REDISCLOUD_URL");
        let subastorage_url =
            std::env::var("SUPABASE_URL_STORAGE").expect("missing SUPABASE_URL_STORAGE");
        let subastorage_key = std::env::var("SUPABASE_API_KEY").expect("missing SUPABASE_API_KEY");
        let region = std::env::var("REGION");
        let region_provider = RegionProviderChain::first_try(region.map(Region::new).ok())
            .or_default_provider()
            .or_else(Region::new("us-east-1"));
        let shared_config = aws_config::from_env().region(region_provider).load().await;
        let dynamo_db = aws_sdk_dynamodb::Client::new(&shared_config);
        let table_name = std::env::var("TABLE_NAME").expect("missing TABLE_NAME");
        let ai_api_url = std::env::var("AI_API_URL").expect("missing AI_API_URL");
        let anime_db_url = std::env::var("ANIME_DB_URL").expect("missing ANIME_DB_URL");
        let llm_api_key = std::env::var("LLM_API_KEY").expect("missing LLM_API_KEY");
        let llm_model_name = std::env::var("LLM_MODEL_NAME").expect("missing LLM_MODEL_NAME");
        let llm_api_url = std::env::var("LLM_API_URL").expect("missing LLM_API_URL");
        let secrets = Secrets {
            mal_client_id,
            bearer_secret,
            rediscloud_url,
            subastorage_url,
            subastorage_key,
            dynamo_db,
            table_name,
            ai_api_url,
            anime_db_url,
            llm_api_key,
            llm_model_name,
            llm_api_url,
        };

        Config { secrets, base_url }
    }
}
