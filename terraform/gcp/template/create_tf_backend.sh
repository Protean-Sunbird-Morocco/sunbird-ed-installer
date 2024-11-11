#!/bin/bash
set -euo pipefail

# Set the path to service account key file for authentication
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/key.json" 

# Check if authentication file exists
if [[ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]]; then
    echo "Error: key.json file not found in the current directory."
    exit 1
fi

# Initialize variables
environment=dev
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="devtfstate-1731053316"  # Static bucket name
LOCATION="asia-south1"  # Choose an appropriate location for your bucket

# Check if the bucket already exists
if gsutil ls -b "gs://$BUCKET_NAME" &>/dev/null; then
    echo "Bucket $BUCKET_NAME already exists."
else
    echo "Bucket $BUCKET_NAME does not exist. Creating it now..."
    # Create the GCP storage bucket (only if it doesn't exist)
    gsutil mb -p "$PROJECT_ID" -l "$LOCATION" "gs://$BUCKET_NAME"
    # Enable versioning on the bucket for safety
    gsutil versioning set on "gs://$BUCKET_NAME"
fi

# Create a terraform backend configuration file
echo "export GCP_TERRAFORM_BACKEND_BUCKET=$BUCKET_NAME" > tf.sh
echo "export GCP_PROJECT_ID=$PROJECT_ID" >> tf.sh
echo "export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/key.json" >> tf.sh  # Include this for manual Terraform commands

echo -e "\nIf you need to run terraform commands manually, run the following command in your terminal to export the necessary environment variables"

echo "source tf.sh"

