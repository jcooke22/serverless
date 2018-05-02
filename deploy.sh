#!/usr/bin/env bash

BUCKET_NAME=ea-serverless
APP_NAME=james-example

# Check if the bucket already exists
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'
then
    # Create the bucket, as it wasn't found
    aws s3 mb s3://${BUCKET_NAME} --region eu-west-2
fi

sam validate

sam package --template-file template.yaml \
    --s3-bucket ${BUCKET_NAME} \
    --output-template-file packaged.yaml

aws cloudformation deploy \
   --template-file packaged.yaml \
   --stack-name ${APP_NAME} \
   --capabilities CAPABILITY_IAM