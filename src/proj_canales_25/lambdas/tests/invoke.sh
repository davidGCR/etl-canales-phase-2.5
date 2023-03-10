#!/bin/bash
# while getopts n:c: option
# do 
#     case "${option}"
#         in
#         n)function_name=${OPTARG};;
#         c)code=${OPTARG};;
#     esac
# done

while getopts n:t: flag
do
    case "${flag}" in
        n) function_name=${OPTARG};;
        t) token=${OPTARG};;
    esac
done

echo "function_name : $function_name"
echo "token   : $token"

# aws lambda invoke --function-name $function_name --cli-binary-format raw-in-base64-out --payload $token out.txt
aws lambda invoke --function-name $function_name --cli-binary-format raw-in-base64-out --payload file://$token out.txt
LOG_GROUP=/aws/lambda/$function_name
MSYS_NO_PATHCONV=1 aws logs tail $LOG_GROUP --follow

# MSYS_NO_PATHCONV=1 aws logs get-log-events --log-group-name /aws/lambda/auna-dl-qa-prueba-file-validator_v2 --log-stream-name stream1 --limit 5