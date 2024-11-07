#!/bin/bash

# Step 1: Dependency Check
echo "Checking dependencies..."
sleep 2
sudo apt-get update && sudo apt-get install -y python3 python3-pip
pip3 install --upgrade pip --break-system-packages boto3==1.34.135 pyarrow==14.0.1 numpy==1.26.0

echo "Dependencies installed."
sleep 2

# Step 2: S3 Bucket Selection
echo "Do you want to use an existing S3 bucket for logs, or create a new one?"
echo "1. Use existing S3 bucket"
echo "2. Create new S3 bucket"
read -p "Select an option (1 or 2): " bucket_choice
sleep 1

# If creating new bucket
if [[ "$bucket_choice" == "2" ]]; then
    read -p "Enter a unique name for the new S3 bucket: " new_bucket_name
    export WAZUH_AWS_BUCKET=$new_bucket_name
else
    read -p "Enter the ARN of your existing S3 bucket: " existing_bucket_arn
    export WAZUH_AWS_BUCKET=$existing_bucket_arn
fi

# Step 3: IAM Setup Manual Steps
echo "If you don't have IAM credentials, please follow these steps in AWS Console:"
echo "1. Create an IAM user group."
echo "2. Create an IAM user, add it to the user group, and create access keys."
echo "3. Save the access keys for the next step."
sleep 5

# Step 4: Configure AWS Credentials
echo "Setting up AWS credentials in /root/.aws/credentials..."
aws configure --profile wazuh-profile

# Step 5: Execute Terraform
echo "Starting Terraform to set up AWS CloudTrail and VPC Flow Logs..."
sleep 2
terraform init
terraform apply -var="bucket_name=$WAZUH_AWS_BUCKET" -auto-approve

echo "Setup complete! AWS CloudTrail and VPC Flow Logs are now configured with Wazuh."