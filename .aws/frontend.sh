#!/bin/bash

################################################################################
##
## The following script synchronises frontend resources with dedicated S3 bucket
##
################################################################################

. .env

if [ -z $FRONTEND_BUCKET_NAME ] ; then
  echo "error: FRONTEND_BUCKET_NAME required"
  exit 1
fi

cd ../form
rm -rf dist
npm run build

aws s3 sync dist/ s3://$FRONTEND_BUCKET_NAME/ \
  --cache-control "max-age=300, must-revalidate" \
  --delete
