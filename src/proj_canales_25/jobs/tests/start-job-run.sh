#!/bin/bash

# while getopts n:t: flag
# do
#     case "${flag}" in
#         n) function_name=${OPTARG};;
#         t) token=${OPTARG};;
#     esac
# done

JOB_NAME=canales25_glue_job_1

echo "---> (1) Running: ${JOB_NAME}"
aws glue start-job-run --job-name $JOB_NAME

JOB_ID=$(aws glue get-job-runs --job-name $JOB_NAME --query 'JobRuns[0].Id' --output text)
echo "---> Job Id: ${JOB_ID}"

LOG_GROUP=/aws-glue/jobs/output
# LOG_STREAM=
# sleep 30
# MSYS_NO_PATHCONV=1 aws logs tail $LOG_GROUP --log-stream-names $JOB_ID --follow

while true; do
    sleep 5
    STATUS=$(aws glue get-job-runs --job-name $JOB_NAME --query 'JobRuns[0].JobRunState' --output text)
    echo "Status: ${STATUS}..."
    if [[ "$STATUS" == "SUCCEEDED" ]]; then
        break
    fi
done

MSYS_NO_PATHCONV=1 aws logs tail $LOG_GROUP --log-stream-names $JOB_ID