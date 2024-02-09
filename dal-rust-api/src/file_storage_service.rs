use crate::{config::Config, model::File};
use reqwest::{multipart::Part, Response};

use serde::{Deserialize, Serialize};

pub struct FileStorageService {
    pub config: Config,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignedURLResponse {
    #[serde(rename(serialize = "signedURL", deserialize = "signedURL"))]
    signed_url: String,
}

impl FileStorageService {
    pub async fn get_image_url(
        &self,
        image_type: String,
        image_path: String,
        expiry: i64,
    ) -> SignedURLResponse {
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
            .await
            .unwrap();
        let text: SignedURLResponse = response.json().await.unwrap();
        SignedURLResponse {
            signed_url: format!("{}{}", self.config.secrets.subastorage_url, text.signed_url),
        }
    }

    pub async fn save_image(&self, image_type: String, image_path: String, file: File) {
        let url = format!(
            "{}/object/{}/{}",
            self.config.secrets.subastorage_url, image_type, image_path
        );
        let client = reqwest::Client::new();
        let part = Part::bytes(file.content)
            .file_name(file.file_name)
            .mime_str(&file.content_type)
            .unwrap();
        let file = reqwest::multipart::Form::new().part("file", part);
        let request = client
            .post(url)
            .header("Content-Type", "multipart/form-data")
            .bearer_auth(&self.config.secrets.subastorage_key)
            .multipart(file);
        let response = request.send().await.unwrap();
        self.validate_reponse(response).await;
    }

    async fn validate_reponse(&self, response: Response) -> String {
        let status = response.status();
        let text = response.text().await.unwrap();
        println!("Status: {:?} and Reponse: {}", status, text);
        if status.is_success() {
            return text;
        } else {
            panic!("Error saving image");
        }
    }
}
