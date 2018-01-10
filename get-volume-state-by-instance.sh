#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <instance-id> [<region>]
EOF

check_params $1
get_region $2

INSTANCE_ID=$1

AWS_CMD="aws ec2 describe-volumes \
        --region ${REGION} \
        --filters \
            Name=tag-key,Values=\"instance-id\" \
            Name=tag-value,Values=\"${INSTANCE_ID}\" \
        --query 'Volumes[*].{VolumeId:VolumeId,State:Attachments[0].State}'"
AWK_CMD="awk '\
         /{/ {VOL_ID=\"\"; STATE=\"\";} \
         /VolumeId/ {VOL_ID=\$2} \
         /State/ {STATE=\$2} \
         /}/ {print VOL_ID, STATE; VOL_ID=\"\"; STATE=\"\";}\
         ' | sed 's/[\",]//g'"
PIPE="${AWS_CMD} | ${AWK_CMD}"
eval "${PIPE}"
#eval "${AWS_CMD}" | "${AWK_CMD}"
