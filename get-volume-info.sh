#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <volume-id> [<region>]
EOF

check_params $1
get_region $2

VOLUME_ID=$1

#VOLUME_STATUS=`${DIR}/is-volume-attached.sh ${VOLUME_ID}`
#
#if [ "${VOLUME_STATUS}" == "none" ]; then
#    error_print "Volume ${VOLUME_ID} is not attached to an instance yet."
#fi

INSTANCE_ID=`${DIR}/get-instance-by-attached-volume.sh ${VOLUME_ID} 2>/dev/null`
if [ "$?" -eq "2" ]; then
    error_print "Volume ${VOLUME_ID} not found!"
    exit 1
fi

INSTANCE_STATE=`${DIR}/get-instance-state.sh ${INSTANCE_ID}`
XVD=`${DIR}/map-instance-volume-to-xvds.sh ${INSTANCE_ID} | grep ${VOLUME_ID}`
INT_IP=`${DIR}/get-instance-int-ip.sh ${INSTANCE_ID} 2>/dev/null`
XVD=`echo ${XVD} | sed 's/.* \/dev\/sd/\/dev\/xvd/' | sed 's/[0-9]$//'`
DEV_OK=`${SSH_CMD} -t ubuntu@${INT_IP} "sudo fdisk -l ${XVD} 2>/dev/null | grep \"${XVD}\"" 2>/dev/null`
if [ "${DEV_OK}" != "" ]; then
FDISK_RESULT=`${SSH_CMD} -t ubuntu@${INT_IP} "sudo fdisk -l ${XVD} 2>/dev/null | sed 's/\*//' | awk '/^\/dev/ {PT=NF-1;print \\$1,\\$NF,\\$6}'" 2>/dev/null`
fi
NUM_PARTS=`echo "${FDISK_RESULT}" | grep -c -e "/dev/xvd"`
if [ "${NUM_PARTS}" -eq "1" ]; then

PARTITION=`echo ${FDISK_RESULT} | awk '{print \$1}'`
#PART_TYPE=`echo ${FDISK_RESULT} | awk '{print \$2}' | sed 's/[^A-Za-z /]//g'`
PART_CODE=`echo ${FDISK_RESULT} | awk '{print \$3}' | sed 's/[^A-Za-z0-9 /]//g'`

BLKID_CMD="${SSH_CMD} -t ubuntu@${INT_IP} blkid ${PARTITION} -o export 2>/dev/null"
BLKID_OUT=`${BLKID_CMD} 2>/dev/null | sed 's/\r/\n/g'`
eval "${BLKID_OUT}"

 if [ "${PART_CODE}" -ne "82"  -a  "${PART_CODE}" -ne "83" ]; then
    error_print "Only partition types \"82\" and \"83\" are supported!"
    exit 1
 fi

fi

if [ "${TYPE}" == "swap" ]; then
    TYPE="linux-swap"
fi

cat <<EOF
BLKNAME=${XVD}
DEVNAME=${DEVNAME}
TYPE=${TYPE}
UUID=${UUID}
IP=${INT_IP}
INSTANCE_ID=${INSTANCE_ID}
VOLUME_ID=${VOLUME_ID}
PART_CODE=${PART_CODE}
INSTANCE_STATE=${INSTANCE_STATE}
EOF

exit 0


