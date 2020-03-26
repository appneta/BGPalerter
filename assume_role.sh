#!/usr/bin/env bash
# Source this script in-line in teamcity builds just before triggering jobs that run in other accounts.
# I.e. for packer AMI builds.
#
# Example:
#
# source assume_role dev
#

ACCOUNT=${1}
ROLE=tf-automation-user-role

# Error check
if [ -z ${1} ]; then
  echo "No account specified.  Specify either account alias or account ID.  Example:"
  echo "source assume_role.sh npm-devsandbox"
  echo "    -- or --"
  echo "source assume_role.sh 1234567890"
fi

# Set region
if [ -z ${2+x} ]; then
  AWS_REGION=us-east-1
else
  AWS_REGION=${2}
fi
unset AWS_SESSION_TOKEN
export AWS_REGION=us-east-1

if [[ "${ACCOUNT}" == "aws-appneta-shared" ]] || [[ "${ACCOUNT}" == "shared" ]]; then
  ACCOUNT_ID=178452673432
elif [[ "${ACCOUNT}" == "npm-devsandbox" ]] || [[ "${ACCOUNT}" == "dev" ]] || [[ "${ACCOUNT}" == "pv-dev" ]]; then
  ACCOUNT_ID=883182791440
elif [[ "${ACCOUNT}" == "npm-dev" ]] || [[ "${ACCOUNT}" == "st" ]] || [[ "${ACCOUNT}" == "pv-staging" ]]; then
  ACCOUNT_ID=657125119322
elif [[ "${ACCOUNT}" == "npm-prod" ]] || [[ "${ACCOUNT}" == "prod" ]] || [[ "${ACCOUNT}" == "pv-prod" ]]; then
  ACCOUNT_ID=454704371524
else
  if [[ "178452673432 883182791440 657125119322 454704371524" =~ "${ACCOUNT}" ]]; then
    ACCOUNT_ID=${ACCOUNT}
  else
    echo "Invalid account.  Valid options are shared, dev, st, prod"
    exit 1
  fi
fi

temp_role=$(aws sts assume-role \
                    --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/${ROLE}" \
                    --role-session-name "tc_role_assumption")

export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
