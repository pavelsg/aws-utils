#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <instance-id> [<region>]
EOF
    exit 1    
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$1" == "" ] 
then
    print_help
fi

INSTANCE_ID=$1

if [ "$2" != "" ]
then
    REGION=$2
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

RESULT=`aws ec2 describe-instances --instance-ids ${INSTANCE_ID}`
echo ${RESULT} | sed 's/.*"AvailabilityZone": "//' | sed 's/".*//'
