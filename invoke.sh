#!/bin/sh
set -e

DATA_PATH=${DATA_PATH:-$1} # Get the data dir from the environment first if it exists.
DATA_DIR=$DATA_PATH
DATA_DIR=${DATA_DIR//\//-}
DEBUG_FLAG=$2
SOURCE_DATA="/opt/airflow/working"
METADATA_PATH="/opt/airflow/metadata"
mkdir -p ${METADATA_PATH}

echo "Starting dlme-transform for: ${DATA_PATH}"

OUTPUT_FILENAME="output-$DATA_DIR.ndjson"
SUMMARY_FILEPATH="output/summary-$DATA_DIR.json"

set +e
exe/transform --summary-filepath $SUMMARY_FILEPATH --base-data-dir $SOURCE_DATA --data-dir $DATA_PATH $DEBUG_FLAG | tee "$METADATA_PATH/$OUTPUT_FILENAME"

echo "Dlme-transform complete for: ${DATA_PATH}"
