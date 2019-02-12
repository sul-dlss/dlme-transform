#!/bin/sh
set -e

if [ $SKIP_FETCH_CONFIG != "true" ]; then
  echo "Getting github.com/sul-dlss/dlme-traject"
  curl -L https://github.com/sul-dlss/dlme-traject/archive/master.zip > master.zip
  unzip master.zip *.rb
  mv dlme-traject-master/* /opt/traject/config/
  rm master.zip
fi

if [ $SKIP_FETCH_DATA != "true" ]; then
  echo "Getting github.com/sul-dlss/dlme-metadata"
  curl -L https://github.com/sul-dlss/dlme-metadata/archive/master.zip > master.zip
  unzip master.zip
  mv dlme-metadata-master/* dlme-metadata
  rm master.zip
fi

OUTPUT_FILEPATH="output/output-$(date +%Y%m%d%H%M%S).ndjson"

traject -Ilib -w Traject::JsonWriter $@ | tee $OUTPUT_FILEPATH

if [ -n "$S3_BUCKET" ]; then
  echo "Sending to S3"
  aws s3 cp $OUTPUT_FILEPATH $S3_BUCKET
fi
