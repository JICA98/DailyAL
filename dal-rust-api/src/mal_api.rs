use crate::config::Config;
use crate::model::Anime;
use crate::reqwest;

#[derive(Debug, Clone)]
pub struct MalAPI {
    pub config: Config,
}

impl MalAPI {
    pub async fn get_anime_details(
        &self,
        id: i64,
    ) -> Result<Anime, Box<dyn std::error::Error>> {
        let fields = "?fields=alternative_titles,mean,media_type,status,start_season,related_anime";
        let url = format!("{}/anime/{}{}", self.config.base_url, id, fields);
        let client = reqwest::Client::new();
        let response = client
            .get(&url)
            .header("X-MAL-Client-ID", self.config.secrets.mal_client_id.clone())
            .send()
            .await?
            .text()
            .await?;
        let anime: Anime = serde_json::from_str(&response)?;
        Ok(anime)
    }
}
