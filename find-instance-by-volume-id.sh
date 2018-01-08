#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <volume-id> [<region>]
EOF
    exit 1    
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$1" == "" ] 
then
    print_help
fi

VOLUME_ID=$1

if [ "$2" != "" ]
then
    REGION=$2
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

#AWS_CMD="
FIND_RESULT=`aws ec2 describe-volumes \
        --region ${REGION} \
        --volume-ids "${VOLUME_ID}" 2>/dev/null`
FIND_RET_VAL=$?

if [ ! ${FIND_RET_VAL} -eq 0 ]; then
    echo Error! Unable to find volume! >&2
    exit ${FIND_RET_VAL}
fi

#echo ---
#echo ${FIND_RESULT}
#echo ---

echo ${FIND_RESULT} | grep "\"InstanceId\": \"" >/dev/null 2>&1
GREP_RET_VAL=$?

if [ "${FIND_RET_VAL}${GREP_RET_VAL}" == "01" ]
then
    echo Volume ${VOLUME_ID} is found but not attached to an instance! >&2
    exit 1
fi

RESULT=`echo ${FIND_RESULT} | sed 's/.*"InstanceId": "//' | sed 's/".*//'`
if [ "${FIND_RESULT}" != "[]" ]
then
    echo ${RESULT}
    exit 0
fi
