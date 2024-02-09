use crate::{
    cache_service::CacheService,
    file_storage_service::{FileStorageService, SignedURLResponse}, model::File,
};

pub struct ImageService {
    pub storage_service: FileStorageService,
    pub cache_service: CacheService,
}
impl ImageService {
    pub async fn get_image_url(&self, image_type: String, image_id: String) -> SignedURLResponse {
        if image_type != "user-bgs" {
            panic!("Invalid image type");
        }
        let cached_image: Option<SignedURLResponse> = self
            .cache_service
            .get_by_id(image_type.as_str(), image_id.clone())
            .await;
        match cached_image {
            Some(response) => response,
            None => {
                let expiry = 3600 * 24 *30;
                let image_path = format!("public/{}.image", image_id);
                let signed_urlresponse = self
                    .storage_service
                    .get_image_url(image_type.to_string(), image_path, expiry)
                    .await;
                self.cache_service
                    .set_by_id(&image_type, image_id, &signed_urlresponse, Some(expiry))
                    .await;
                signed_urlresponse
            }
        }
    }

    pub async fn save_image(&self, image_type: String, image_id: String, file: File) {
        if image_type != "user-bgs" {
            panic!("Invalid image type");
        }
        let image_path = format!("public/{}.image", image_id);
        self.storage_service
            .save_image(image_type.to_string(), image_path, file)
            .await;
        self.cache_service
            .delete_by_id(image_type.as_str(), image_id)
            .await;
    }
    
}
