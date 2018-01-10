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

if [ "${INSTANCE_ID}" == "" ]; then
    error_print "Volume ${VOLUME_ID} is not attached to an instance yet."
    exit 1
fi

INSTANCE_STATE=`${DIR}/get-instance-state.sh ${INSTANCE_ID}`

if [ "${INSTANCE_STATE}" != "running" ]; then
    error_print "Instance is not running! Unable to check file-system type!"
    exit 1
fi

XVD=`${DIR}/map-instance-volume-to-xvds.sh ${VOLUME_ID}`

echo ${XVD}
