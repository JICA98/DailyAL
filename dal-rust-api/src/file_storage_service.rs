use crate::{config::Config, model::File};
use reqwest::{header::HeaderValue, Body, Response};

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
        println!("Hitting url: {}", url);
        let client: reqwest::Client = reqwest::Client::new();
        let request = client
            .post(url)
            .header(
                "Content-Type",
                HeaderValue::from_str(&file.content_type).unwrap(),
            )
            .bearer_auth(&self.config.secrets.subastorage_key)
            .body(Body::from(file.content));
        let response = request.send().await.unwrap();
        validate_reponse(response).await;
    }

    pub async fn delete_image(&self, image_type: String, image_path: String) {
        let url = format!(
            "{}/object/{}/{}",
            self.config.secrets.subastorage_url, image_type, image_path
        );
        println!("Hitting url: {}", url);
        let client: reqwest::Client = reqwest::Client::new();
        let response = client
            .delete(url)
            .bearer_auth(&self.config.secrets.subastorage_key)
            .send()
            .await
            .unwrap();
        validate_reponse(response).await;
    }
}

async fn validate_reponse(response: Response) -> String {
    let status = response.status();
    let text = response.text().await.unwrap();
    println!("Status: {:?} and Reponse: {}", status, text);
    if status.is_success() {
        return text;
    } else {
        panic!("Error saving image");
    }
}
