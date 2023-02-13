#!/bin/sh
set -e

DATA_PATH=${DATA_PATH:-$1} # Get the data dir from the environment first if it exists.
DATA_DIR=$DATA_PATH
DATA_DIR=${DATA_DIR//\//-}
DEBUG_FLAG=$2
DOWNLOAD_PATH=${DATA_PATH%/*}
SOURCE_DATA="/opt/airflow/working/$DATA_PATH"
METADATA_PATH="/opt/airflow/metadata/$DATA_PATH"
mkdir -p ${METADATA_PATH}

mkdir -p /opt/traject/data
cp -R $SOURCE_DATA /opt/traject/data/$DOWNLOAD_PATH

echo "Starting dlme-transform for: ${DATA_PATH}"

OUTPUT_FILENAME="output-$DATA_DIR.ndjson"
SUMMARY_FILEPATH="output/summary-$DATA_DIR.json"

set +e
exe/transform --summary-filepath $SUMMARY_FILEPATH --data-dir $DATA_PATH $DEBUG_FLAG | tee "$METADATA_PATH/$OUTPUT_FILENAME"

echo "Dlme-transform complete for: ${DATA_PATH}"
