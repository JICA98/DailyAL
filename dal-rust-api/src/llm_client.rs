use serde_json::json;

use crate::{config::Config, model::OpenAIResponse};

#[derive(Debug, Clone)]
pub struct LLMClient {
    pub config: Config,
}

impl LLMClient {
    pub async fn talk(
        &self,
        system: &str,
        prompt: &str,
    ) -> Result<String, Box<dyn std::error::Error + Send + Sync>> {
        let llm_api_key = self.config.secrets.llm_api_key.as_str();
        let api_url = self.config.secrets.llm_api_url.as_str();
        println!("Calling LLM...");

        let client = reqwest::Client::new();

        let request_body = json!({
            "model": self.config.secrets.llm_model_name,
            "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.6,
            "top_p": 0.7,
            "max_tokens": 4096,
            "stream": false
        });

        let res = client
            .post(api_url)
            .header("Authorization", format!("Bearer {}", llm_api_key))
            .header("Content-Type", "application/json")
            .json(&request_body)
            .send()
            .await?;

        let status = res.status();
        let text = res.text().await?;

        if !status.is_success() {
            println!("LLM API failed with status {}: {}", status, text);
            return Err(format!("LLM API failed with status {}: {}", status, text).into());
        }

        let response: OpenAIResponse = serde_json::from_str(&text)
            .map_err(|e| format!("Failed to parse JSON: {} | Response Text: '{}'", e, text))?;

        if let Some(choice) = response.choices.first() {
            Ok(choice.message.content.clone())
        } else {
            Err(format!("LLM API returned no choices! Response: {}", text).into())
        }
    }
}
