#!/usr/bin/env bash

OUTPUT_NAME="$1"
shift

OUTPUT_FOLDER="output/$OUTPUT_NAME/"

if [[ ! -d "$OUTPUT_FOLDER" ]]; then
    echo "error: output folder does not exist: $OUTPUT_FOLDER" >&2
    exit 1
fi

mkdir -p indexes/

clip-retrieval index \
    --embeddings_folder "$OUTPUT_FOLDER" \
    --index-folder "index/$OUTPUT_NAME/" \
    $@
