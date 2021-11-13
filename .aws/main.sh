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

stack_name=$PROJECT
stack_output_file=$stack_name-output.txt

echo "Creating resources for $PROJECT project ..."
aws cloudformation create-stack --stack-name $stack_name \
  --template-body file://main.yml \
  --parameters ParameterKey=ProjectName,ParameterValue=$PROJECT \
  ParameterKey=TableName,ParameterValue=$TABLE \
  --tags Key=project,Value=$PROJECT \
  --region $REGION \
  --capabilities CAPABILITY_NAMED_IAM \
  --output text > stack_output_file 

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