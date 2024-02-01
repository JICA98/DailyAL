use crate::AppState;
use axum::{
    body::Body,
    extract::State,
    http::{header, Request, StatusCode},
    middleware::Next,
    response::IntoResponse,
    Json,
};
use serde::Serialize;
use std::sync::Arc;

#[derive(Debug, Serialize)]
pub struct ErrorResponse {
    pub status: &'static str,
    pub message: String,
}

pub async fn auth(
    State(data): State<Arc<AppState>>,
    req: Request<Body>,
    next: Next,
) -> Result<impl IntoResponse, (StatusCode, Json<ErrorResponse>)> {
    let token_opt = req
        .headers()
        .get(header::AUTHORIZATION)
        .and_then(|auth_header| auth_header.to_str().ok())
        .and_then(|token| {
            if token.starts_with("Bearer") {
                Some(token[7..].to_string())
            } else {
                None
            }
        });

    let token_result = token_opt.ok_or_else(|| {
        let json_error = ErrorResponse {
            status: "fail",
            message: "No token found to validate".to_string(),
        };
        (StatusCode::UNAUTHORIZED, Json(json_error))
    });

    let secret = data.config.secrets.bearer_secret.as_ref();
    match token_result {
        Ok(token) => {
            if token == secret {
                Ok(next.run(req).await)
            } else {
                let json_error = ErrorResponse {
                    status: "fail",
                    message: "Provided token is invalid".to_string(),
                };
                Err((StatusCode::UNAUTHORIZED, Json(json_error)))
            }
        }
        Err(err) => Err(err),
    }
}
