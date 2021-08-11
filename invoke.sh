#!/bin/sh
set -e

if [ $SKIP_FETCH_DATA != "true" ]; then
  echo "Getting github.com/sul-dlss/dlme-metadata"
  curl -L https://github.com/sul-dlss/dlme-metadata/archive/main.zip > main.zip
  unzip -q main.zip
  mkdir -p /opt/traject/data
  mv dlme-metadata-main/* /opt/traject/data
  rm main.zip
fi

DATA_DIR=$@
DATA_DIR=${DATA_DIR//\//-}
OUTPUT_FILENAME="output-$DATA_DIR.ndjson"
OUTPUT_FILEPATH="output/$OUTPUT_FILENAME"
SUMMARY_FILEPATH="output/summary-$DATA_DIR.json"

set +e
exe/transform --summary-filepath $SUMMARY_FILEPATH --data-dir $@ | tee $OUTPUT_FILEPATH

if [ -n "$PUSH_TO_AWS" ]; then
  echo "Logging into AWS DevelopersRole"
  temp_role=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
              AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        aws sts assume-role \
        --role-session-name "DevelopersRole" \
        --role-arn $DEV_ROLE_ARN)
  export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
  export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
  export AWS_SESSION_TOKEN=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
fi

if [ -n "$S3_BUCKET" ]; then
  if [ -n "$S3_ENDPOINT_URL" ]; then
    S3_ENDPOINT_URL_ARG="--endpoint-url=$S3_ENDPOINT_URL"
  fi

  echo "Sending to S3"
  aws s3 cp $OUTPUT_FILEPATH s3://$S3_BUCKET --acl public-read $S3_ENDPOINT_URL_ARG

  # Add url to summary
  mv $SUMMARY_FILEPATH $SUMMARY_FILEPATH.tmp
  jq ".url = \"$S3_BASE_URL/$S3_BUCKET/$OUTPUT_FILENAME\"" $SUMMARY_FILEPATH.tmp > $SUMMARY_FILEPATH
  rm $SUMMARY_FILEPATH.tmp
fi

if [ -n "$SNS_TOPIC_ARN" ]; then
  if [ -n "$SNS_ENDPOINT_URL" ]; then
    SNS_ENDPOINT_URL_ARG="--endpoint-url=$SNS_ENDPOINT_URL"
  fi
  echo "Sending notification to SNS"
  aws sns publish --topic-arn $SNS_TOPIC_ARN --message file://$SUMMARY_FILEPATH $SNS_ENDPOINT_URL_ARG
fi
