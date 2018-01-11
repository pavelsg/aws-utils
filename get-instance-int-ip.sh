#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <instance-id> [<region>]
EOF

check_params $1
get_region $2

INSTANCE_ID=$1

AWS_CMD="aws ec2 describe-instances \
         --instance-ids ${INSTANCE_ID} \
         --output text \
         --query 'Reservations[0].Instances[0].{IntIp:PrivateIpAddress}'"

INT_IP=`eval ${AWS_CMD}`
RET_VAL=$?
echo ${INT_IP}
exit ${RET_VAL}
