#!/bin/bash

# --- Nettoyage des anciennes ressources (évite le ResourceConflictException) ---
echo "--- Nettoyage ---"
awslocal lambda delete-function --function-name EC2Manager 2>/dev/null || true
# Supprime l'API existante si elle porte le même nom
EXISTING_API_ID=$(awslocal apigateway get-rest-apis --query "items[?name=='EC2ControlAPI'].id" --output text)
if [ "$EXISTING_API_ID" != "None" ] && [ -n "$EXISTING_API_ID" ]; then
    awslocal apigateway delete-rest-api --rest-api-id $EXISTING_API_ID
fi

# 1. Création de l'instance EC2
echo "--- Création de l'EC2 ---"
INSTANCE_ID=$(awslocal ec2 run-instances --image-id ami-ff0fea83 --count 1 --instance-type t2.micro --query 'Instances[0].InstanceId' --output text)
echo "Instance ID: $INSTANCE_ID"

# 2. Préparation de la Lambda
zip function.zip lambda_function.py
awslocal lambda create-function \
    --function-name EC2Manager --runtime python3.9 \
    --zip-file fileb://function.zip --handler lambda_function.lambda_handler \
    --role arn:aws:iam::000000000000:role/lambda-role --timeout 10 \
    --environment "Variables={AWS_ENDPOINT=http://localhost.localstack.cloud:4566,INSTANCE_ID=$INSTANCE_ID}"

# 3. Création de l'API Gateway
API_ID=$(awslocal apigateway create-rest-api --name 'EC2ControlAPI' --query 'id' --output text)
PARENT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)

for action in start stop status; do
    RES_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $PARENT_ID --path-part $action --query 'id' --output text)
    awslocal apigateway put-method --rest-api-id $API_ID --resource-id $RES_ID --http-method GET --authorization-type "NONE"
    awslocal apigateway put-integration --rest-api-id $API_ID --resource-id $RES_ID --http-method GET --type AWS_PROXY \
        --integration-http-method POST --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:EC2Manager/invocations
done

awslocal apigateway create-deployment --rest-api-id $API_ID --stage-name prod

echo "------------------------------------------------"
echo "✅ Déploiement terminé sur charles-cloud.local !"
echo "URL : http://charles-cloud.local:4566/restapis/$API_ID/prod/_user_request_/control"
echo "ID : $INSTANCE_ID"
echo "------------------------------------------------"
