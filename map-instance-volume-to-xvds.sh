#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <instance-id> [<region>]
EOF
    exit 1    
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$1" == "" ] 
then
    print_help
fi

INSTANCE_ID=$1

if [ "$2" != "" ]
then
    REGION=$2
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

if [ "${REGION}" == "" ]
then
    >&2 echo Failed to discover default region, bailing out!
    exit 1
fi

AWS_CMD="aws ec2 describe-volumes \
         --filters Name=\"attachment.instance-id\",Values=\"${INSTANCE_ID}\" \
         --region ${REGION}"
AWK_CMD="awk '/\"Attachments\": \[/ {VOL_ID=\"\"; MNT=\"\"} \
              /^\s+\"VolumeId\":/ {VOL_ID=\$2} \
              /^\s+\"Device\":/ {MNT=\$2} \
              /\}/ {if (VOL_ID != \"\" && MNT != \"\") {print VOL_ID, MNT; VOL_ID=\"\"; MNT=\"\"}}'"
SED_CMD="sed 's/[\",]//g'"

FULL_CMD="${AWS_CMD} | ${AWK_CMD} | ${SED_CMD}"

# CMD_RESULT=`${AWS_CMD}`
#${AWS_CMD} | ${AWK_CMD}
#echo test | ${AWK_CMD}
eval ${FULL_CMD}
LIST_RET_VAL=$?
exit ${LIST_RET_VAL}
