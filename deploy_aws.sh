#!/bin/bash

# 1. Création de l'instance EC2 "Cible"
echo "--- Création de l'EC2 ---"
INSTANCE_ID=$(awslocal ec2 run-instances --image-id ami-ff0fea83 --count 1 --instance-type t2.micro --query 'Instances[0].InstanceId' --output text)
echo "Instance ID: $INSTANCE_ID"

# 2. Préparation de la Lambda
echo "--- Création de la Lambda ---"
zip function.zip lambda_function.py

awslocal lambda create-function \
    --function-name EC2Manager \
    --runtime python3.9 \
    --zip-file fileb://function.zip \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::000000000000:role/lambda-role

# 3. Création de l'API Gateway
echo "--- Création de l'API Gateway ---"
API_ID=$(awslocal apigateway create-rest-api --name 'EC2ControlAPI' --query 'id' --output text)
PARENT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)

# Création de la ressource /control
RESOURCE_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $PARENT_ID --path-part control --query 'id' --output text)

# Création de la méthode GET
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method GET --authorization-type "NONE"

# Intégration de la Lambda à l'API
awslocal apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $RESOURCE_ID \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:EC2Manager/invocations

# Déploiement de l'API
awslocal apigateway create-deployment --rest-api-id $API_ID --stage-name prod

echo "------------------------------------------------"
echo "✅ Déploiement terminé !"
echo "URL de l'API : http://localhost:4566/restapis/$API_ID/prod/_user_request_/control"
echo "Instance ID à piloter : $INSTANCE_ID"
echo "------------------------------------------------"
# ... (début du script inchangé)

echo "--- Création de la Lambda ---"
zip function.zip lambda_function.py

awslocal lambda create-function \
    --function-name EC2Manager \
    --runtime python3.9 \
    --zip-file fileb://function.zip \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --environment "Variables={AWS_ENDPOINT_URL=http://localhost.localstack.cloud:4566}"

# ... (reste du script)
