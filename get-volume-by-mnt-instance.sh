#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <mount> <instance-id> [<region>]
EOF
    exit 1    
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$2" == "" ] 
then
    print_help
fi

MOUNT=$1
INSTANCE_ID=$2

get_region $3

#AWS_CMD="
FIND_RESULT=`aws ec2 describe-volumes \
        --region ${REGION} \
        --filters \
            Name=tag-key,Values=\"instance-id\" \
            Name=tag-value,Values=\"${INSTANCE_ID}\" \
            Name=tag-key,Values=\"mount\" \
            Name=tag-value,Values=\"${MOUNT}\" \
        --query 'Volumes[*].{ID:VolumeId,Tag:Tags}'`

#RESULT=`${AWS_CMD}`
RESULT=`echo ${FIND_RESULT} | sed 's/.*"ID": "//' | sed 's/".*//'`
if [ "${RESULT}" != "[]" ]
then
    echo Volume ${MOUNT}@${INSTANCE_ID} already exists.
    exit 0
fi
echo Volume ${MOUNT}@${INSTANCE_ID} not found!
exit 2
