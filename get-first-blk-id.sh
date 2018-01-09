#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <space-separated device list>
EOF
    exit 1
}

if [ "$1" == "" ]
then
    print_help
fi

if [ "$2" != "" ]
then
    echo Multiple parameters not supported.
    echo To pass multiple block devices use quotas
    exit 1
fi

if [ "/dev/sd*" != "" ]
then 
    echo Seems like wrong parameters passed.
    echo Expected in form of "/dev/sda /dev/sdb ..."
    exit 2
fi

USED_LETTERS=`echo $1 | sed 's/\/dev\/sd//g'  | sed 's/ //g'`
# looks like Amazon reservs from 'a' to 'd'
ALPHABET="fghijklmnopqrstuvwxyz"
FIRST_FREE=`echo ${ALPHABET} | sed 's/['${USED_LETTERS}']//g' | sed 's/\(.\).*/\1/'`
echo ${FIRST_FREE}
