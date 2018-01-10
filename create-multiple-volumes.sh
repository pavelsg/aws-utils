#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <instance-id> <volume file> [<region>]
EOF
    exit 1
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$2" == "" ] 
then
    print_help
fi

if [ "$3" != "" ]
then
    REGION=$3
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

VOL_LIST=$2
INSTANCE_ID=$1

while IFS=: read -r TYPE SIZE MOUNT
do
    #printf 'Type: %s, Size: %s, Mount: %s\n' "${TYPE}" "${SIZE}" "${MOUNT}"
    ${DIR}/create-volume.sh ${TYPE} ${SIZE} ${MOUNT} ${INSTANCE_ID} ${REGION}
    if [ $? -ne 0 ]
    then
        >&2 echo Error creating volumes, bailing out!
        exit 1
    fi
done <"${VOL_LIST}"
