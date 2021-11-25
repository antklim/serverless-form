#!/bin/bash

################################################################################
##
## The following script deploys changes in API
##
################################################################################

. .env

if [ -z $API_ID ] ; then
  echo "error: API_ID required"
  exit 1
fi
if [ -z $STAGE ] ; then
  echo "error: STAGE required"
  exit 1
fi

aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name $STAGE