sudo docker build . -t dal_rust_api
sudo docker tag dal_rust_api jica98/dal_rust_api:latest
sudo docker push jica98/dal_rust_api:latest