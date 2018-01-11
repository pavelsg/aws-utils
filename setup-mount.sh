#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <volume-id> [<region>]
EOF

check_params $1
get_region $2

VOLUME_ID=$1

DISK_INFO=`${DIR}/get-volume-info.sh ${VOLUME_ID} ${REGION}`

eval "${DISK_INFO}"

if [ "${IP}" == "" -o "${BLKNAME}" == "" ]; then
    error_print "Unable to get volume information for volume ${VOLUME_ID}"
    exit 1
fi

MOUNT=`${DIR}/get-volume-tags.sh ${VOLUME_ID} | awk '/mount/ {print \$2}'`

if [ "${MOUNT}" != "swap" ]; then
    MKFS_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo mkfs -F -t ${TYPE} ${DEVNAME} | grep UUID" 2>/dev/null`
else
    echo Creating swap
fi

