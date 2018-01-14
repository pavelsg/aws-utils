#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/functions.sh

read -r -d '' MSG_USAGE <<EOF
Usage: $0 <ip> <partition> <file-system> <uuid> <mount-point>  
EOF

check_params $5
# get_region $2

IP=$1
PARTITION=$2
FS_TYPE=$3
UUID=$4
MOUNT=$5
BLKNAME=`echo ${PARTITION} | sed 's/[0-9]$//'`

if [ "${FS_TYPE}" == "swap" ]; then
    echo No mount point is necessary for swap.
    exit 0
fi

MOUNT_OUT=`${SSH_CMD} -t ubuntu@${IP} "mount | grep ${PARTITION} | wc -l 2>/dev/null" | sed 's/\r/\n/' 2>/dev/null`
if [ "${MOUNT_OUT}" -ge "1" ]; then
    error_print "Partition is already mounted! Aborting!"
    exit 1
fi

FSTAB_MOUNT=`${SSH_CMD} -t ubuntu@${IP} "grep ${MOUNT} /etc/fstab 2>/dev/null" 2>/dev/null`
FSTAB_UUID=`${SSH_CMD} -t ubuntu@${IP} "grep ${UUID} /etc/fstab 2>/dev/null" 2>/dev/null`
FSTAB_DEV=`${SSH_CMD} -t ubuntu@${IP} "grep ${PARTITION} /etc/fstab 2>/dev/null" 2>/dev/null`
if [ "${FSTAB_MOUNT}${FSTAB_UUID}${FSTAB_DEV}" != "" ]; then
    error_print "Partition is already listed in /etc/fstab. Aborting!"
    exit 1
fi

MOUNT_OUT=`${SSH_CMD} -t ubuntu@${IP} "mount | grep ${MOUNT} 2>/dev/null" | sed 's/\r/\n/' 2>/dev/null`
if [ "${MOUNT_OUT}" != "" ]; then
    echo "Mountpoint ${MOUNT} is busy. Unmounting."
    UMOUNT_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo umount ${MOUNT} 2>/dev/null" 2>/dev/null`
fi

if [ "${MOUNT}" != "swap" ]; then
    MKFS_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo mkdir -p ${MOUNT} 2>/dev/null" 2>/dev/null`
else
    MOUNT="none"
fi

case ${MOUNT} in
    /tmp)
        MNT_OPTS="rw,noexec,nodev,nosuid"
        ;;
    /export/storage*)
        MNT_OPTS="defaults,noatime,discard"
        ;;
    swap)
        MNT_OPS="sw"
        ;;
    *)
        MNT_OPTS="defaults,nodev,nosuid"
        ;;
esac

FSTAB_LINE="UUID=${UUID}\\\t${MOUNT}\\\t${FS_TYPE}\\\t${MNT_OPTS}\\\t0\ 0"
EDIT_FSTAB=`${SSH_CMD} -t ubuntu@${IP} "echo -e ${FSTAB_LINE} | sudo tee --append /etc/fstab 2>/dev/null" 2>/dev/null`

if [ "${MOUNT}" == "swap" ]; then
    SWAP_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo swapon --all 2>/dev/null" 2>/dev/null`
    exit 0
fi

if [ "${MOUNT}" == "/tmp" -o "${MOUNT}" == "/var" -o "${MOUNT}" == "/home" ]; then
    # Re-mounting ${MOUNT}
read -r -d '' PART_SH <<PART
init 1\\\n
cd /\\\n
mv ${MOUNT} ${MOUNT}.old\\\n
mkdir ${MOUNT}\\\n
mount ${PARTITION} ${MOUNT}\\\n
init 5\\\n
PART
    ECHO_OUT=`${SSH_CMD} -t ubuntu@${IP} "echo -e "${PART_SH}" >part.sh 2>/dev/null" 2>/dev/null`
    MKDIR_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo mkdir /mnt${MOUNT} 2>/dev/null" 2>/dev/null`
    MOUNT_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo mount ${PARTITION} /mnt${MOUNT} 2>/dev/null" 2>/dev/null`
    CP_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo cp -ax ${MOUNT}/* /mnt${MOUNT} 2>/dev/null" 2>/dev/null`
    UMOUNT_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo umount /mnt${MOUNT} 2>/dev/null" 2>/dev/null`
    PART_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo bash part.sh 2>/dev/null" 2>/dev/null`
else
    MKDIR_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo mkdir -p ${MOUNT} 2>/dev/null" 2>/dev/null`
    MOUNT_OUT=`${SSH_CMD} -t ubuntu@${IP} "sudo mount ${PARTITION} ${MOUNT} 2>/dev/null" 2>/dev/null`
fi
