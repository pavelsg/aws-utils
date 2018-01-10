#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <instance-id> [<region>]
EOF

check_params $1
get_region $2

INSTANCE_ID=$1


