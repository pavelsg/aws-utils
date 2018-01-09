#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <volume-id> [<instance-id>] [<region>]
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

${DIR}/is-volume-attached.sh ${VOLUME_ID} &>/dev/null
IS_RET_VAL=$?
if [ ${IS_RET_VAL} -eq 0 ]
then
    echo Volume is already attached, bailing out!
    exit 1
fi

if [ "$3" != "" ]
then
    REGION=$3
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

if [ "$2" != "" ]
then
    INSTANCE_ID=$2
#    echo instance specified: $2
else
    INSTANCE_ID=`${DIR}/get-volume-tags.sh ${VOLUME_ID} | grep instance-id | sed 's/instance-id //'`
#  sed 's/instance-id //'
#    discover instance-id from volume tags
fi

if [ "${INSTANCE_ID}" == "" ]
then
    echo Unable to auto-discover instance-id from volume tag
    exit 2
fi

#AWS_CMD="

USED_LETTER=`${DIR}/get-instance-xvds.sh ${INSTANCE_ID}`
FIRST_LETTER=`${DIR}/get-first-blk-id.sh "${USED_LETTER}"`

if [ "${FIRST_LETTER}" == "" ] 
then
    echo Unable to find free drive letter, bailing out!
    exit 1
fi

aws ec2 attach-volume --device /dev/sd${FIRST_LETTER} --instance-id ${INSTANCE_ID} --volume-id ${VOLUME_ID}
