#!/bin/bash
set -euo pipefail

if [ $# -lt 3 ]; then
  echo "Usage: $0 <stack-name> <template-file> <parameters-file> [region]"
  echo "Example: $0 my-network templates/network.yml parameters/dev/network.json"
  exit 1
fi

STACK_NAME=$1
TEMPLATE=$2
PARAMETERS=$3
REGION=${4:-us-east-1}

aws cloudformation create-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://"$TEMPLATE" \
  --parameters file://"$PARAMETERS" \
  --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
  --region "$REGION"

echo "Creating stack: $STACK_NAME in $REGION..."
echo "Waiting for stack creation to complete..."

aws cloudformation wait stack-create-complete \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo "Stack $STACK_NAME created successfully."
