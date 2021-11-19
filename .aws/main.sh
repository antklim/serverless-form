#!/bin/bash

. .env

REGION=${REGION:-"ap-southeast-2"}

if [ -z $PROJECT ] ; then
  echo "error: PROJECT required"
  exit 1 
fi
if [ -z $TABLE ] ; then
  echo "error: TABLE required"
  exit 1 
fi
if [ -z $API_RESOURCE ] ; then
  echo "error: API_RESOURCE required"
  exit 1
fi
if [ -z $FRONTEND_BUCKET_NAME ] ; then
  echo "error: FRONTEND_BUCKET_NAME required"
  exit 1
fi

stack_name=$PROJECT
stack_output_file=$stack_name-output.txt

stacks=$(aws cloudformation describe-stacks \
  --query "Stacks[?StackName=='$stack_name']" \
  --output json | jq '. | length')

if [ $stacks -eq 0 ] ; then
  echo "Creating resources for $PROJECT project ..."
  aws cloudformation create-stack --stack-name $stack_name \
    --template-body file://main.yml \
    --parameters ParameterKey=ProjectName,ParameterValue=$PROJECT \
    ParameterKey=TableName,ParameterValue=$TABLE \
    ParameterKey=ApiResource,ParameterValue=$API_RESOURCE \
    ParameterKey=FrontendBucketName,ParameterValue=$FRONTEND_BUCKET_NAME \
    --tags Key=project,Value=$PROJECT \
    --region $REGION \
    --capabilities CAPABILITY_NAMED_IAM \
    --output text > $stack_output_file

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to initiate stack $stack_name"
    exit 1
  fi

  echo "Waiting for resources creation completion ..."
  aws cloudformation wait stack-create-complete --stack-name $stack_name

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to create stack $stack_name"
    exit 1
  fi

  echo "$PROJECT resources successfully created."
else
  echo "Updating resources for $PROJECT project ..."

  aws cloudformation update-stack --stack-name $stack_name \
    --template-body file://main.yml \
    --parameters ParameterKey=ProjectName,UsePreviousValue=true \
    ParameterKey=TableName,UsePreviousValue=true \
    ParameterKey=ApiResource,UsePreviousValue=true \
    ParameterKey=FrontendBucketName,UsePreviousValue=true \
    --region $REGION \
    --capabilities CAPABILITY_NAMED_IAM \
    --output text > $stack_output_file

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to initiate stack update $stack_name"
    exit 1
  fi

  echo "Waiting for resources update completion ..."
  aws cloudformation wait stack-update-complete --stack-name $stack_name

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to update stack $stack_name"
    exit 1
  fi

  echo "$PROJECT resources successfully updated."
fi
