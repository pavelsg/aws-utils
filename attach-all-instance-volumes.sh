#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <instance-id> [<region>]
EOF

check_params $1
get_region $2

INSTANCE_ID=$1

UNATTACHED_VOLUMES="${DIR}/get-volume-state-by-instance.sh ${INSTANCE_ID} | awk '/null/ {print \$1}'"
eval ${UNATTACHED_VOLUMES} | xargs -n 1 ${DIR}/attach-volume.sh
