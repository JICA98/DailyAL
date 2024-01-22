mkdir -p build/lambda
dart compile exe bin/dal_api.dart -o build/lambda/bootstrap
cd build/lambda
zip lambda.zip bootstrap
aws lambda update-function-code --function-name dal_lambda --zip-file fileb://./lambda.zip