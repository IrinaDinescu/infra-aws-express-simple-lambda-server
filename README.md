# infra-aws-express-simple-lambda-server

## Overview

This project demonstrates how to create an AWS Lambda function using Node.js, Express, and TypeScript. The function is deployed using AWS CloudFormation and can be run locally for testing and development.

## Features

- **AWS Lambda**: Run serverless functions.
- **Express**: Framework for building web applications and APIs.
- **TypeScript**: Superset of JavaScript with static types.
- **AWS CloudFormation**: Infrastructure as Code for deploying AWS resources.
- **Local Development**: Tools to run Lambda functions locally.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Node.js**: Version 20.x or higher
- **npm**: Version 10.7.x or higher
- **AWS CLI**: Installed and configured
- **Docker**: (Optional) For running Lambda functions locally
- **AWS SAM CLI**: (Optional) For local Lambda function testing

## Installation

1. **Clone the Repository**

   ```sh
   git clone https://github.com/IrinaDinescu/infra-aws-express-simple-lambda-server.git
   cd infra-aws-express-simple-lambda-server
   ```

## Build and Deploy

To deploy your Lambda function, follow these steps to execute the `deploy.sh` script:

1. **Build and deploy**

   Run the script.

   ```sh
   chmod +x deploy.sh
   ./deploy.sh
   ```
