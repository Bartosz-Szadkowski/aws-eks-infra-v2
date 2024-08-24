#!/bin/bash

set -e

# Variables
S3_BUCKET="my-terraform-esta-state"
DYNAMODB_TABLE="my-lock-esta-table"
REGION="us-east-1"

# Check if S3 bucket exists
if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
    echo "S3 bucket $S3_BUCKET already exists."
else
    echo "Creating S3 bucket $S3_BUCKET..."
    
    if [ "$REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "$S3_BUCKET" --region "$REGION"
    else
        aws s3api create-bucket --bucket "$S3_BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
    fi
    
    echo "Enabling versioning on S3 bucket $S3_BUCKET..."
    aws s3api put-bucket-versioning --bucket "$S3_BUCKET" --versioning-configuration Status=Enabled
fi

# Check if DynamoDB table exists
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" 2>/dev/null; then
    echo "DynamoDB table $DYNAMODB_TABLE already exists."
else
    echo "Creating DynamoDB table $DYNAMODB_TABLE..."
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$REGION"
    echo "Waiting for DynamoDB table $DYNAMODB_TABLE to be active..."
    aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE"
fi

echo "S3 bucket and DynamoDB table are set up."