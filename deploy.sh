#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
STACK_NAME="express-simple-lambda-server"
TEMPLATE_FILE="infra/service.yaml"
S3_BUCKET="myirinabucketforlambdafunction"
DEPLOY_PACKAGE="lambda-deployment-package.zip"
STACK_INFO_FILE="stack_info.json"

# Function to clean up deployment directory, ZIP file, and stack info file
cleanup() {
    echo "Cleaning up..."
    rm -rf deploy $DEPLOY_PACKAGE $STACK_INFO_FILE
}

# Trap any script exit (error or success) and run the cleanup function
trap cleanup EXIT

# Log the start of the script
echo "Starting deployment script..."

# Run the build script to compile TypeScript or perform other build tasks
echo "Running build..."
npm run build

# Create a 'deploy' directory if it does not already exist
echo "Creating deploy directory..."
mkdir -p deploy

# Copy the compiled code and necessary dependency files into the 'deploy' directory
echo "Copying files to deploy directory..."
cp -r dist deploy/
cp package.json package-lock.json deploy/

# Change directory to 'deploy' to prepare for packaging
echo "Changing directory to deploy..."
cd deploy

# Install only the production dependencies listed in package.json
echo "Installing production dependencies..."
npm install --production

# Create a ZIP file of the contents in the 'deploy' directory
# Excludes unnecessary files like .git and markdown files
echo "Creating deployment package..."
zip -r ../$DEPLOY_PACKAGE *

# Change back to the original directory
echo "Changing back to the original directory..."
cd ..

# Check if the S3 bucket exists
echo "Checking if S3 bucket exists..."
if ! aws s3api head-bucket --bucket $S3_BUCKET 2>/dev/null; then
    echo "S3 bucket does not exist. Creating a new bucket..."
    aws s3api create-bucket --bucket $S3_BUCKET --region $(aws configure get region) --create-bucket-configuration LocationConstraint=$(aws configure get region)
else
    echo "S3 bucket already exists."
fi

# Upload the deployment package to the specified S3 bucket
echo "Uploading deployment package to S3..."
aws s3 cp $DEPLOY_PACKAGE s3://$S3_BUCKET/

# Check if the stack exists
echo "Checking if stack exists..."
STACK_EXISTS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME 2>&1 || true)

if echo "$STACK_EXISTS" | grep -q "does not exist"; then
    echo "Stack does not exist. Creating a new stack..."
    aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --capabilities CAPABILITY_IAM
else
    echo "Stack exists. Checking for updates..."

    # Update the CloudFormation stack
    UPDATE_OUTPUT=$(aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --capabilities CAPABILITY_IAM 2>&1 || true)

    if echo "$UPDATE_OUTPUT" | grep -q "No updates are to be performed"; then
        echo "No stack updates are needed. Updating the function code..."

        # Get the current Lambda function name
        FUNCTION_NAME=$(aws cloudformation describe-stack-resource --stack-name $STACK_NAME --logical-resource-id MyLambdaFunction --query 'StackResourceDetail.PhysicalResourceId' --output text)

        # Update the Lambda function code and suppress output
        aws lambda update-function-code --function-name $FUNCTION_NAME --s3-bucket $S3_BUCKET --s3-key $DEPLOY_PACKAGE > /dev/null
    else
        echo "Stack update initiated."
    fi
fi

# Retrieve and display information about the updated or newly created CloudFormation stack
echo "Retrieving stack information..."
aws cloudformation describe-stacks --stack-name $STACK_NAME > $STACK_INFO_FILE
cat $STACK_INFO_FILE

# Log the end of the script
echo "Deployment script completed."

# Exit the script
exit 0
