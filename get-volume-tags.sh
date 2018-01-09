#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <volume-id> [<region>]
EOF
    exit 1
}

if [ "$1" == "" ]
then
    print_help
fi

if [ "$2" != "" ]
then
    REGION=$2
#    echo region specified: $2
else
    REGION=`aws configure get default.region`
#    echo using default region
fi

VOLUME_ID=$1

aws ec2 describe-volumes --volume-ids ${VOLUME_ID}| sed -e '1,/"Tags":/d' -e '/]/,$d' | awk 'BEGIN {KEY=""; VALUE="";} /^\s+"Value"/ {VALUE=$2} /^\s+"Key"/ {KEY=$2} /^\s+},?/ {print KEY, VALUE}' | sed 's/[",]//g'
