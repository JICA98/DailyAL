sudo docker build . -t dal_api
sudo docker tag dal_api jica98/dal-api:latest
sudo docker push jica98/dal-api:latest