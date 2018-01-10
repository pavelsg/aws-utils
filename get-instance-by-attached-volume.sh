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

get_region $2

#AWS_CMD="
FIND_RESULT=`aws ec2 describe-volumes \
        --region ${REGION} \
        --volume-ids "${VOLUME_ID}" 2>/dev/null`
FIND_RET_VAL=$?

if [ ! ${FIND_RET_VAL} -eq 0 ]; then
    error_print "Error! Unable to find volume!"
    exit ${FIND_RET_VAL}
fi

echo ${FIND_RESULT} | grep "\"InstanceId\": \"" >/dev/null 2>&1
GREP_RET_VAL=$?

if [ "${FIND_RET_VAL}${GREP_RET_VAL}" == "01" ]
then
    error_print "Volume ${VOLUME_ID} is found but not attached to an instance!"
    exit 1
fi

RESULT=`echo ${FIND_RESULT} | sed 's/.*"InstanceId": "//' | sed 's/".*//'`
if [ "${FIND_RESULT}" != "[]" ]
then
    echo ${RESULT}
    exit 0
fi
