#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <instance-id> <volume type> <volume size> <mount-point> [<region>]
EOF

check_params $4
get_region $5

INSTANCE_ID=$1
TYPE=$2
SIZE=$3
MOUNT=$4

#echo "${DIR}/create-volume.sh ${TYPE} ${SIZE} ${MOUNT} ${INSTANCE_ID} ${REGION}"
    #printf 'Type: %s, Size: %s, Mount: %s\n' "${TYPE}" "${SIZE}" "${MOUNT}"
    echo "${DIR}/create-volume.sh ${TYPE} ${SIZE} ${MOUNT} ${INSTANCE_ID} ${REGION}"
    CV_OUT=`${DIR}/create-volume.sh ${TYPE} ${SIZE} ${MOUNT} ${INSTANCE_ID} ${REGION} | awk '/Created volume: / {print $NF}' `
    if [ $? -ne 0 ]
    then
        >&2 echo Error creating volumes, bailing out!
        exit 1
    fi
    sleep 10
    echo "${DIR}/attach-volume.sh ${CV_OUT} ${INSTANCE_ID} ${REGION}"
    ATT_OUT=`${DIR}/attach-volume.sh ${CV_OUT} ${INSTANCE_ID} ${REGION}`
    sleep 5
    echo "${DIR}/create-partition.sh ${CV_OUT} ${REGION}"
    PART_OUT=`${DIR}/create-partition.sh ${CV_OUT} ${REGION}`
    echo "${DIR}/get-volume-info.sh ${CV_OUT} ${REGION}"
    VOL_INFO=`${DIR}/get-volume-info.sh ${CV_OUT} ${REGION}`
    eval "${VOL_INFO}"
    FS_TYPE="ext4"
    if [ "${MOUNT}" == "swap" ]; then
        FS_TYPE=swap
    fi
    echo "${DIR}/create-file-system.sh ${IP} ${DEVNAME} ${FS_TYPE}"
    MKFS_OUT=`${DIR}/create-file-system.sh ${IP} ${DEVNAME} ${FS_TYPE}`
    echo "${DIR}/setup-mount-point.sh ${IP} ${DEVNAME} ${FS_TYPE} ${MKFS_OUT} ${MOUNT}"
    MOUNT_OUT=`${DIR}/setup-mount-point.sh ${IP} ${DEVNAME} ${FS_TYPE} ${MKFS_OUT} ${MOUNT}`

