#!/bin/bash

################################################################################
##
## The following creates AWS WAFv2 WebACL. 
##
## Because it's for CLOUDFRONT distribution, it must be created in
## the US East (N. Virginia) Region, us-east-1.
## 
################################################################################

. .env

WAF_REGION="us-east-1"

stack_name=$PROJECT-waf
stack_output_file=$stack_name-output.txt

stacks=$(aws cloudformation describe-stacks \
  --query "Stacks[?StackName=='$stack_name']" \
  --region $WAF_REGION \
  --output json | jq '. | length')

if [ $stacks -eq 0 ] ; then
  echo "Creating WAF for $PROJECT project ..."
  aws cloudformation create-stack --stack-name $stack_name \
    --template-body file://waf.yml \
    --parameters ParameterKey=ProjectName,ParameterValue=$PROJECT \
    --tags Key=project,Value=$PROJECT \
    --region $WAF_REGION \
    --output text > $stack_output_file

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to initiate stack $stack_name"
    exit 1
  fi

  echo "Waiting for resources creation completion ..."
  aws cloudformation wait stack-create-complete --stack-name $stack_name \
    --region $WAF_REGION

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to create stack $stack_name"
    exit 1
  fi

  echo "$PROJECT WAF successfully created."
else
  echo "Updating WAF for $PROJECT project ..."
  aws cloudformation update-stack --stack-name $stack_name \
    --template-body file://waf.yml \
    --parameters ParameterKey=ProjectName,UsePreviousValue=true \
    --region $WAF_REGION \
    --output text > $stack_output_file

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to initiate stack update $stack_name"
    exit 1
  fi

  echo "Waiting for resources update completion ..."
  aws cloudformation wait stack-update-complete --stack-name $stack_name \
    --region $WAF_REGION

  status=$?
  if [ $status -ne 0 ] ; then
    echo "error: failed to update stack $stack_name"
    exit 1
  fi

  echo "$PROJECT WAF successfully updated."
fi