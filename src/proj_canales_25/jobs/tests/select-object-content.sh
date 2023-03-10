#!/bin/bash
bucket=auna-dlaqa-raw-s3
key=structured-data/OLAP/Modama/dashboard_canales/telemarketing

aws --output text s3api list-objects-v2 \
    --bucket $bucket \
    --prefix $key \
    --query 'Contents[?ends_with(Key, `parquet`)]|[*].[Key]' | awk '{print $1}' | while read line;
    do aws s3api select-object-content \
        --bucket $bucket \
        --key $line \
        --expression 'select * from s3object limit 10' \
        --expression-type SQL \
        --input-serialization '{"Parquet": {}}' \
        --output-serialization '{"CSV": {}}' \
        $(dirname "$0")/$(basename $(dirname $line)).csv;
    done

# aws s3api select-object-content \
#     --bucket $bucket \
#     --key $key/part-00000-3c4f9c6c-e173-4410-821a-a416de9d4503-c000.gz.parquet \
#     --expression 'select count(*) from s3object' \
#     --expression-type SQL \
#     --input-serialization '{"Parquet": {}}' \
#     --output-serialization '{"CSV": {}}' \
#     /dev/stdout


