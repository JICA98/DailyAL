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
    ) -> Result<crate::model::Anime, Box<dyn std::error::Error>> {
        let fields = "?fields=mean,media_type,status,start_season,related_anime";
        let url = format!("{}/anime/{}{}", self.config.base_url, id, fields);
        let client = reqwest::Client::new();
        Ok(client
            .get(&url)
            .header("X-MAL-Client-ID", self.config.secrets.mal_client_id.clone())
            .send()
            .await?
            .json::<Anime>()
            .await?
        )
    }
}
