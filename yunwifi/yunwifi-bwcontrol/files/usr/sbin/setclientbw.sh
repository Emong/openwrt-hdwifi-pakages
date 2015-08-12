#!/bin/sh
# Copyright (C) 2014 Emong
# http://blog.emong.me

IP=$(echo $1 | awk -F . '{print $4}' | awk -F / '{print $1}')
MASK=$(echo $1 | awk -F . '{print $4}' | awk -F / '{print $2}')
#for big network,if want work with netmask comment it.
["$MASK" == "" ] && MASK=$(echo $1 | awk -F . '{print $3}')
CLASSID=$(echo $IP|awk '{printf("%02x\n",$0)}')$(echo $MASK|awk '{printf("%02x\n",$0)}')

HIP=$1
DOWNRATE=$2
UPRATE=$3
[ "$DOWNRATE" = "0" -o "$UPRATE" = "0" ] && {
	echo "bandwith 0 means no limit!"
	echo "Exit!"
	exit 1
} 
isin=$(tc class show dev ifb0 classid 1:$CLASSID)
[ "$isin" = "" ] && {
	tc class add dev ifb0 parent 1: classid 1:$CLASSID htb rate ${DOWNRATE}kbit
	tc qdisc add dev ifb0 parent 1:$CLASSID handle $CLASSID sfq perturb 10
	tc filter add dev ifb0 protocol ip prio 1 u32 match ip dst $HIP flowid 1:$CLASSID
	
	tc class add dev ifb1 parent 1: classid 1:$CLASSID htb rate ${UPRATE}kbit
	tc qdisc add dev ifb1 parent 1:$CLASSID handle $CLASSID sfq perturb 10
	tc filter add dev ifb1 protocol ip prio 1 u32 match ip src $HIP flowid 1:$CLASSID

	exit 0
}
echo "has done! only reset bandwidth"
tc class ch dev ifb0 parent 1: classid 1:$CLASSID htb rate ${DOWNRATE}kbit
tc class ch dev ifb1 parent 1: classid 1:$CLASSID htb rate ${UPRATE}kbit
exit 0
