read -r -d '' MSG_PARAMS_MISSING <<EOF
Some parameters are missing!
EOF

SSH_CMD="ssh -oStrictHostKeyChecking=no -i  ~/.ssh/aws-key.pem "

function error_print() {
    >&2 echo "$1"
}

# Pass last required param here
function check_params () {
    if [ "$1" == "" ] ; then
        error_print "${MSG_PARAMS_MISSING}"
        echo "${MSG_USAGE}"
        exit 1
    fi
}

function get_region() {
    if [ "$1" == "" ] ; then
        REGION=`aws configure get default.region`
    else
        REGION=$1
    fi
}
