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

PART_TYPE="ext4"
MOUNT=`${DIR}/get-volume-tags.sh ${VOLUME_ID} | awk '/mount/ {print \$2}'`
if [ "${MOUNT}" == "swap" ]; then
    PART_TYPE="linux-swap"
fi

PART_MATCH="[ \"${DEVNAME}\" != \"\" -a \"${PART_TYPE}\" == \"${TYPE}\" ]"
if ${PART_MATCH}; then
    echo "File-system type for ${DEVNAME} matches configuration. Exiting."
    exit 0
fi

ABORT="[ \"${DEVNAME}\" != \"\" -a \"${PART_TYPE}\" != \"${TYPE}\" -a \"${FDISK_OVERRIDE}\" != \"1\" ]"
if ${ABORT}; then
    error_print "Partition with different file-system already exists! Set environment variable FDISK_OVERRIDE=1 to ignore!"
    exit 1
fi

OVERRIDE="[ \"${DEVNAME}\" != \"\" -a \"${PART_TYPE}\" != \"${TYPE}\" -a \"${FDISK_OVERRIDE}\" == \"1\" ]"
if ${OVERRIDE}; then
    # delete_partition.sh ${IP} ${DEVNAME}
    echo override enabled, deleting partition ${DEVNAME}
    PART_NUM=`echo ${DEVNAME} | sed 's/^.*\([0-9]\)$/\1/'`
    PART_RM=`${SSH_CMD} -t ubuntu@${IP} "sudo parted ${BLKNAME} --script -- rm ${PART_NUM}" 2>/dev/null`
fi

PART_LBL=`${SSH_CMD} -t ubuntu@${IP} "sudo parted ${BLKNAME} --script -- mklabel msdos" 2>/dev/null`
PART_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo parted -a optimal ${BLKNAME} --script -- mkpart primary ${PART_TYPE} 0 -1" 2>/dev/null`

