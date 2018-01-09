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

USED_LETTERS=`echo $1 | sed 's/\/dev\/sd//g'  | sed 's/ //g'`
ALPHABET="abcdfghijklmnopqrstuvwxyz"
FIRST_FREE=`echo ${ALPHABET} | sed 's/['${USED_LETTERS}']//g' | sed 's/\(.\).*/\1/'`
echo ${FIRST_FREE}
