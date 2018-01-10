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

INSTANCE_ID=`${DIR}/get-instance-by-attached-volume.sh ${VOLUME_ID}`
if [ "${INSTANCE_ID}" != "" ]
then
    error_print "Volume ${VOLUME_ID} is already attached, bailing out!"
    exit 1
fi

get_region $3

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
    >&2 echo Unable to auto-discover instance-id from volume tag
    exit 2
fi

#AWS_CMD="

USED_LETTER=`${DIR}/get-instance-xvds.sh ${INSTANCE_ID}`
if [ ! $? -eq 0 ]
then
    >&2 echo Unable to list block devices for an instance!
    exit 2
fi

FIRST_LETTER=`${DIR}/get-first-blk-id.sh "${USED_LETTER}"`

if [ "${FIRST_LETTER}" == "" ] 
then
    >&2 echo Unable to find free drive letter, bailing out!
    exit 1
fi

aws ec2 attach-volume --device /dev/sd${FIRST_LETTER} --instance-id ${INSTANCE_ID} --volume-id ${VOLUME_ID}
AWS_RESULT=$?
if [ "${AWS_RESULT}" -eq 0 ] 
then
    echo Volume ${VOLUME_ID} attached to ${INSTANCE_ID} as /dev/sd${FIRST_LETTER}
fi

