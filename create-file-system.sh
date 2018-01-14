#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <ip> <partition> <file-system>
EOF

check_params $3
# get_region $2

IP=$1
PARTITION=$2
FS_TYPE=$3
BLKNAME=`echo ${PARTITION} | sed 's/[0-9]$//'`

if [ "${MOUNT}" != "swap" ]; then
    MKFS_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo mkfs -F -t ${FS_TYPE} ${PARTITION} | grep UUID" 2>/dev/null`
fi

echo ${MKFS_OUT} | awk '{print $NF}' 
