#!/bin/sh
set -e

if [ $USE_GITHUB = "true" ]; then
  echo "Getting github.com/sul-dlss/dlme"
  curl -L https://github.com/sul-dlss/dlme/archive/master.zip > master.zip
  unzip master.zip dlme-master/lib/*
  mv dlme-master/lib .
  rm -fr dlme-master
  rm master.zip

  # Necessary until DLME extracted from rails.
  sed -i 's/delegate/# delegate/g' lib/traject/dlme_json_resource_writer.rb


  echo "Getting github.com/sul-dlss/dlme-metadata"
  curl -L https://github.com/sul-dlss/dlme-metadata/archive/master.zip > master.zip
  unzip master.zip
  mv dlme-metadata-master dlme-metadata
  rm master.zip
fi

traject -Ilib -w Traject::JsonWriter $@ | tee output/output.json
