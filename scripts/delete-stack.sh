#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <stack-name> [region]"
  echo "Example: $0 my-network"
  exit 1
fi

STACK_NAME=$1
REGION=${2:-us-east-1}

echo "Deleting stack: $STACK_NAME in $REGION..."

aws cloudformation delete-stack \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo "Waiting for stack deletion to complete..."

aws cloudformation wait stack-delete-complete \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo "Stack $STACK_NAME deleted successfully."
