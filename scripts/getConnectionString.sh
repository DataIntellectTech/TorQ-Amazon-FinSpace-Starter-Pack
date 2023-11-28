#!/bin/bash

clusterName="${1}"

region="us-east-1"

environmentId="33c4rqbmsx7bjclrrwb2gc"

role_name="finspace-role-virginia"

user_name="finspace-user-virginia"

role_arn="arn:aws:iam::766012286003:role/${role_name}"

user_arn="arn:aws:finspace:${region}:766012286003:kxEnvironment/${environmentId}/kxUser/${user_name}"

export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn $role_arn \
--role-session-name "connect-to-finTorq" \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))

aws finspace get-kx-connection-string --region $region --environment-id $environmentId --user-arn $user_arn  --cluster-name $clusterName