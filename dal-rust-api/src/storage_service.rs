use crate::config::Config;
use serde::{Deserialize, Serialize};

pub struct StorageService {
    pub config: Config,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignedURLResponse {
    #[serde(alias = "signedURL")]
    signed_url: String,
}

impl StorageService {
    pub async fn get_image_url(&self, image_type: String, image_path: String, expiry: i64) -> SignedURLResponse {
        let body = format!(r#"{{ "expiresIn": {} }}"#, expiry);
        let url = format!(
            "{}/object/sign/{}/{}",
            self.config.secrets.subastorage_url, image_type, image_path
        );
        println!("Hitting url: {}", url);
        let client = reqwest::Client::new();
        let response = client
            .post(url)
            .bearer_auth(&self.config.secrets.subastorage_key)
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await.unwrap();
        let text: SignedURLResponse = response.json().await.unwrap();
        SignedURLResponse {
            signed_url: format!("{}{}", self.config.secrets.subastorage_url, text.signed_url),
        }
    }
}
