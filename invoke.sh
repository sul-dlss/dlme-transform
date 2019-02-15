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

OUTPUT_FILEPATH="output/output-$(date +%Y%m%d%H%M%S).ndjson"

exe/transform --data-dir $@ | tee $OUTPUT_FILEPATH

if [ -n "$S3_BUCKET" ]; then
  echo "Sending to S3"
  aws s3 cp $OUTPUT_FILEPATH $S3_BUCKET --acl public-read
fi
