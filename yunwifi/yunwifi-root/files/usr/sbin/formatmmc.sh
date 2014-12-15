#!/bin/sh
DISK=/dev/mmcblk0
[ -e $DISK ] || exit 1
PART_FILE=/tmp/mmcpart
fdisk -l /dev/mmcblk0 |grep mmcblk0p |awk '{print "d";print substr($1,14,1)}' >$PART_FILE
fdisk $DISK << EOF
`cat $PART_FILE`
n
p
1


w
EOF
echo $?
sleep 3
mkfs.ext4 /dev/mmcblk0p1
sleep 3
rm $PART_FILE
reboot
