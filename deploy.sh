#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
STACK_NAME="express-simple-lambda-server"
TEMPLATE_FILE="infra/service.yaml"
S3_BUCKET="myirinabucketforlambdafunction"
DEPLOY_PACKAGE="lambda-deployment-package.zip"

# Function to clean up deployment directory and ZIP file
cleanup() {
    echo "Cleaning up..."
    rm -rf deploy $DEPLOY_PACKAGE
}

# Trap any script exit (error or success) and run the cleanup function
trap cleanup EXIT

# Run the build script to compile TypeScript or perform other build tasks
npm run build

# Create a 'deploy' directory if it does not already exist
mkdir -p deploy

# Copy the compiled code and necessary dependency files into the 'deploy' directory
cp -r dist deploy/
cp package.json package-lock.json deploy/

# Change directory to 'deploy' to prepare for packaging
cd deploy

# Install only the production dependencies listed in package.json
npm install --production

# Create a ZIP file of the contents in the 'deploy' directory
# Excludes unnecessary files like .git and markdown files
zip -r ../$DEPLOY_PACKAGE *

# Change back to the original directory
cd ..

# Upload the deployment package to the specified S3 bucket
aws s3 cp $DEPLOY_PACKAGE s3://$S3_BUCKET/

# Check if the stack exists
STACK_EXISTS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME 2>&1 || true)

if echo "$STACK_EXISTS" | grep -q "does not exist"; then
    echo "Stack does not exist. Creating a new stack."
    aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --capabilities CAPABILITY_IAM
else
    echo "Stack exists. Updating the existing stack."
    aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --capabilities CAPABILITY_IAM
fi

# Retrieve and display information about the updated or newly created CloudFormation stack
aws cloudformation describe-stacks --stack-name $STACK_NAME

# Deletes the 'deploy' directory and the ZIP file to keep the working directory clean
rm -rf deploy $DEPLOY_PACKAGE

# Exit the script
exit 0
