#!/bin/sh
# Copyright (C) 2014 Emong
# http://blog.emong.me

IP=$(echo $1 | awk -F . '{print $4}' | awk -F / '{print $1}')
MASK=$(echo $1 | awk -F . '{print $4}' | awk -F / '{print $2}')
CLASSID=$(echo $IP|awk '{printf("%02x\n",$0)}')$(echo $MASK|awk '{printf("%02x\n",$0)}')


isin=$(tc class show dev ifb0 classid 1:$CLASSID)
[ "$isin" = "" ] && {
	echo "No Such Rule"
	exit 1
}
tmp=$(tc fi show dev ifb0 |grep "flowid 1:$CLASSID" |awk '{print $10}')

#tc filter del dev ifb0 protocol ip prio 1 u32 match ip dst 192.168.1.$IP flowid 1:$IP
tc filter del dev ifb0 parent 1: prio 1 handle $tmp u32
tc qdisc del dev ifb0 parent 1:$CLASSID handle $CLASSID sfq perturb 10
tc class del dev ifb0 classid 1:$CLASSID

#tc filter del dev ifb1 protocol ip prio 1 u32 match ip src 192.168.1.$IP flowid 1:$IP
tmp=$(tc fi show dev ifb1 |grep "flowid 1:$CLASSID" |awk '{print $10}')
tc filter del dev ifb1 parent 1: prio 1 handle $tmp u32
tc qdisc del dev ifb1 parent 1:$CLASSID handle $CLASSID sfq perturb 10
tc class del dev ifb1 classid 1:$CLASSID

exit 0
