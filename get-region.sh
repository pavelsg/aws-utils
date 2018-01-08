#!/bin/bash

function print_help() {
    echo Parameters missing
    cat <<EOF
    Usage: $0 <region> <instance-id>
EOF
    
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

if [ "$2" == "" ] 
then
    print_help
else
    echo "Param #2: $2"
fi

echo ${SSH_CMD}
