#!/usr/bin/env bash

# The S3 bucket name where your application will be stored.
# S3 bucket names are globally unique, so you must ensure
# that the bucket does not already exist within another
# organisation.
BUCKET_NAME=ea-serverless

# The name of your application. This is used within
# CloudFormation and Lambda to define the name of
# your application.
APP_NAME=james-example

# Check if the bucket already exists
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'
then
    # Create the bucket, as it wasn't found
    aws s3 mb s3://${BUCKET_NAME} --region eu-west-2
fi

# Ensure that your SAM template file is correctly formatted
sam validate

# Create a package file which contains a resolved reference
# to the S3 uploaded code asset filename, as well as the
# final version of what will be deployed to the cloud.
sam package --template-file template.yaml \
    --s3-bucket ${BUCKET_NAME} \
    --output-template-file packaged.yaml

# Deploy the package.yaml file which was previously built.
aws cloudformation deploy \
   --template-file packaged.yaml \
   --stack-name ${APP_NAME} \
   --capabilities CAPABILITY_IAM