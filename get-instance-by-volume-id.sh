#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <volume-id> [<region>]
EOF
    exit 1    
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$1" == "" ] 
then
    print_help
fi

VOLUME_ID=$1

if [ "$2" != "" ]
then
    REGION=$2
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

INSTANCE_ID=`aws ec2 describe-volumes \
           --volume-ids ${VOLUME_ID} 2>/dev/null | \
           sed -e '1,/"Attachments": \[/d' -e '/]/,$d' | \
           grep "InstanceId" | \
           sed 's/[",:]//g' | \
           sed 's/ .*InstanceId //'`
echo ${INSTANCE_ID}
exit 0

