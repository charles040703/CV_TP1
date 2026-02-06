#!/bin/bash
set -euo pipefail

REGION="us-east-1"
API_NAME="EC2ControlAPI"
LAMBDA_NAME="EC2Manager"
STAGE="prod"
PORT="4566"

# GitHub Codespaces : variables dynamiques fournies automatiquement
CODESPACE_NAME="${CODESPACE_NAME:-$(hostname)}"
DOMAIN="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
HOST_DOMAIN="${CODESPACE_NAME}-${PORT}.${DOMAIN}"

echo "🚀 Déploiement avec Codespace: ${HOST_DOMAIN}"

# Nettoyage...
echo "--- Nettoyage ---"
awslocal lambda delete-function --function-name "$LAMBDA_NAME" 2>/dev/null || true

EXISTING_API_ID=$(awslocal apigateway get-rest-apis \
  --region "$REGION" \
  --query "items[?name=='$API_NAME'].id" \
  --output text 2>/dev/null || echo "None")

[ "$EXISTING_API_ID" != "None" ] && [ -n "$EXISTING_API_ID" ] && \
  awslocal apigateway delete-rest-api --rest-api-id "$EXISTING_API_ID" --region "$REGION"

# EC2
echo "--- Création de l'EC2 ---"
INSTANCE_ID=$(awslocal ec2 run-instances \
  --region "$REGION" \
  --image-id ami-ff0fea83 \
  --count 1 \
  --instance-type t2.micro \
  --query 'Instances[0].InstanceId' \
  --output text)
echo "Instance ID: $INSTANCE_ID"

# Lambda
echo "--- Création de la Lambda ---"
zip -q function.zip lambda_function.py
awslocal lambda create-function \
  --region "$REGION" \
  --function-name "$LAMBDA_NAME" \
  --runtime python3.9 \
  --zip-file fileb://function.zip \
  --handler lambda_function.lambda_handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --timeout 10 \
  --environment "Variables={INSTANCE_ID=$INSTANCE_ID}"

# API Gateway
echo "--- Création de l'API Gateway REST ---"
API_ID=$(awslocal apigateway create-rest-api \
  --region "$REGION" \
  --name "$API_NAME" \
  --query 'id' \
  --output text)

PARENT_ID=$(awslocal apigateway get-resources \
  --region "$REGION" \
  --rest-api-id "$API_ID" \
  --query 'items[0].id' \
  --output text)

for action in start stop status; do
  echo "  Création /$action..."
  RES_ID=$(awslocal apigateway create-resource \
    --region "$REGION" \
    --rest-api-id "$API_ID" \
    --parent-id "$PARENT_ID" \
    --path-part "$action" \
    --query 'id' \
    --output text)

  awslocal apigateway put-method \
    --region "$REGION" \
    --rest-api-id "$API_ID" \
    --resource-id "$RES_ID" \
    --http-method GET \
    --authorization-type "NONE"

  awslocal apigateway put-integration \
    --region "$REGION" \
    --rest-api-id "$API_ID" \
    --resource-id "$RES_ID" \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/arn:aws:lambda:${REGION}:000000000000:function:${LAMBDA_NAME}/invocations"
done

awslocal apigateway create-deployment \
  --region "$REGION" \
  --rest-api-id "$API_ID" \
  --stage-name "$STAGE"

for action in start stop status; do
  awslocal lambda add-permission \
    --region "$REGION" \
    --function-name "$LAMBDA_NAME" \
    --statement-id "apigw-$action" \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:${REGION}:000000000000:${API_ID}/*/GET/${action}" \
    >/dev/null 2>&1 || true
done

# ✅ URLs DYNAMIQUES (copier-coller directement)
BASE_URL="https://${HOST_DOMAIN}/restapis/${API_ID}/${STAGE}/_user_request_"

echo "------------------------------------------------"
echo "✅ Déploiement terminé ! Instance: $INSTANCE_ID"
echo ""
echo "Voici les 3 URL de pilotage de votre instance EC2 :"
echo "🔴 START  : ${BASE_URL}/start"
echo "🟡 STATUS : ${BASE_URL}/status" 
echo "🟢 STOP   : ${BASE_URL}/stop"
echo ""
echo "💡 Testez avec : curl \"${BASE_URL}/status\""
echo "------------------------------------------------"
