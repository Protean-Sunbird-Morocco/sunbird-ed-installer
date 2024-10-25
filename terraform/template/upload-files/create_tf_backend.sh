#!/bin/bash
set -euo pipefail

environment=dev
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${environment}tfstate-$(date +%s)"
LOCATION="asia-south1"  # Choose an appropriate location for your bucket

# Create a new GCP storage bucket
gsutil mb -p "$PROJECT_ID" -l "$LOCATION" "gs://$BUCKET_NAME"

# Enable versioning on the bucket for safety
gsutil versioning set on "gs://$BUCKET_NAME"

# Create a terraform backend configuration file
echo "export GCP_TERRAFORM_BACKEND_BUCKET=$BUCKET_NAME" > tf.sh
echo "export GCP_PROJECT_ID=$PROJECT_ID" >> tf.sh

echo -e "\nIf you need to run terraform commands manually, run the following command in your terminal to export the necessary environment variables"

echo "source tf.sh" 
