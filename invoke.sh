#!/bin/sh
set -e

if [ $SKIP_FETCH_CONFIG != "true" ]; then
  echo "Getting github.com/sul-dlss/dlme-traject"
  curl -L https://github.com/sul-dlss/dlme-traject/archive/master.zip > master.zip
  unzip master.zip *.rb
  mkdir -p /opt/traject/config/
  mv dlme-traject-master/* /opt/traject/config/
  rm master.zip
fi

if [ $SKIP_FETCH_DATA != "true" ]; then
  echo "Getting github.com/sul-dlss/dlme-metadata"
  curl -L https://github.com/sul-dlss/dlme-metadata/archive/master.zip > master.zip
  unzip master.zip
  mkdir -p /opt/traject/data
  mv dlme-metadata-master/* /opt/traject/data
  rm master.zip
fi

TIMESTAMP=$(date +%Y%m%d%H%M%S)
OUTPUT_FILENAME="output-$TIMESTAMP.ndjson"
OUTPUT_FILEPATH="output/$OUTPUT_FILENAME"
SUMMARY_FILEPATH="output/summary-$TIMESTAMP.json"

set +e
exe/transform --summary-filepath $SUMMARY_FILEPATH --data-dir $@ | tee $OUTPUT_FILEPATH

if [ -n "$S3_BUCKET" ]; then
  echo "Sending to S3"
  aws s3 cp $OUTPUT_FILEPATH s3://$S3_BUCKET --acl public-read

  # Add url to summary
  mv $SUMMARY_FILEPATH $SUMMARY_FILEPATH.tmp
  jq ".url = \"$S3_BASE_URL/$S3_BUCKET/$OUTPUT_FILENAME\"" $SUMMARY_FILEPATH.tmp > $SUMMARY_FILEPATH
  rm $SUMMARY_FILEPATH.tmp
fi

if [ -n "$SNS_TOPIC_ARN" ]; then
  echo "Sending notification to SNS"
  aws sns publish --topic-arn $SNS_TOPIC_ARN --message file://$SUMMARY_FILEPATH
fi
