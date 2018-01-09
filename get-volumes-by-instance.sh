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

#AWS_CMD="aws ec2 describe-volumes --filters Name="attachment.instance-id",Values="i-0675574ef9c3b0906"
LIST_RESULT=`aws ec2 describe-volumes \
        --region ${REGION} \
        --filters Name="attachment.instance-id",Values="${INSTANCE_ID}"`
LIST_RET_VAL=$?
#echo ${LIST_RESULT}
DEV_LIST=`echo ${LIST_RESULT} | grep -o "\"VolumeId\": \"vol-[a-z0-9]\+\"" | sort | uniq | sed 's/"VolumeId": //' | sed 's/"//g'`
echo ${DEV_LIST}
exit ${LIST_RET_VAL}
