#!/bin/bash

function print_help() {
    echo Parameters missing:
    cat <<EOF
    Usage: $0 <size> <type> <mount> <instance-id> [<region>]
           <size> - size of new volume in Gb
           <type> - standard, gp2
EOF
    exit 1
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$4" == "" ]
then
    print_help
fi

if [ "$5" != "" ]
then
    REGION=$5
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

SIZE=$1
TYPE=$2
MOUNT=$3
INSTANCE_ID=$4

FIND_ERR=`${DIR}/find-instance-by-id.sh ${INSTANCE_ID} 2>&1 >/dev/null`
if [ ! $? -eq 0 ]; then
    echo "${FIND_ERR}"
    exit $?
fi

FIND_CMD="${DIR}/find-volume-by-tag.sh ${MOUNT} ${INSTANCE_ID}"
${FIND_CMD} >/dev/null 2>&1

case $? in
    0)
        echo Volume ${MOUNT}@${INSTANCE_ID} already exists, bailing out
        exit 1
        ;;
    1)
        echo Error looking for a ${MOUNT}@${INSTANCE_ID}!
        exit 1
        ;;
    2)
        echo Creating volume ${MOUNT}@${INSTANCE_ID}
        ;;
    *)
        echo Unknown error, bailing out!
        exit 255
        ;;
esac

AVAILABILITY_ZONE=`${DIR}/get-az.sh ${INSTANCE_ID} ${REGION}`

AWS_CMD="aws ec2 create-volume \
    --availability-zone ${AVAILABILITY_ZONE}\
    --size ${SIZE}\
    --volume-type ${TYPE}"
#    --tag-specifications \'ResourceType=volume,Tags=[\{Key=mount,Value=${MOUNT}\},\{Key=instance-id,Value=${INSTANCE_ID}\}]\'
CREATE_RESULT=`${AWS_CMD}`
VOL_ID=`echo ${CREATE_RESULT} | sed 's/.*"VolumeId": "//' | sed 's/".*//'`

aws ec2 create-tags \
     --resources ${VOL_ID} \
     --tags Key=mount,Value=${MOUNT} Key=type,Value=${TYPE} Key=instance-id,Value=${INSTANCE_ID}
echo Created volume: ${VOL_ID}
