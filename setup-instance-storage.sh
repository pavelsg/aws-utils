#!/bin/bash
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <instance-id> <volume file> [<region>]
EOF

check_params $2
get_region $3

INSTANCE_ID=$1
VOL_LIST=$2

cat ${VOL_LIST} | \
    awk -v INSTANCE_ID=${INSTANCE_ID} -v REGION=${REGION} '{print INSTANCE_ID " " $0 " " REGION}' |\
    xargs -I % bash -c '${DIR}/setup-instance-volume.sh %'

exit 0

while IFS=: read -r TYPE SIZE MOUNT
do

    SV_OUT=`${DIR}/setup-instance-volume.sh ${INSTANCE_ID} ${TYPE} ${SIZE} ${MOUNT} ${REGION}`

if [ "${MOUNT}" == "swap" ]; then
echo "Setup completed, rebooting the instance."
REBOOT_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo reboot" 2>/dev/null`
exit 0
fi

done <"${VOL_LIST}"
