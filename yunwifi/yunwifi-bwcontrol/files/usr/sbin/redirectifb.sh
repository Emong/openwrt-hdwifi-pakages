#!/bin/sh
# Copyright (C) 2014 Emong
# http://blog.emong.me

DEVICE=$1
[ "$DEVICE" = "" ] && {
	echo "Use:"
	echo $0 "your LAN interface(normally br-lan)"
	exit 1 
}

        insmod cls_fw
        insmod sch_hfsc
        insmod sch_sfq
        insmod sch_red
        insmod sch_htb
        insmod sch_prio
        insmod ipt_multiport
        insmod ipt_length
        insmod xt_connlimit
        insmod xt_connbytes
        insmod ipt_connbytes
        insmod cls_u32
        insmod em_u32
        insmod act_connmark
        insmod sch_ingress
        insmod act_mirred

	ifconfig ifb0 up
	ifconfig ifb1 up
	
	tc qd del dev $DEVICE root
        tc qdisc del dev $DEVICE handle ffff: ingress

        bwctrl=$(uci get yunwifi.config.bwctrl || echo 1)
        [ "$bwctrl" == "1" ] && {
                tc qdisc add dev $DEVICE root handle 1: htb
                tc filter add dev $DEVICE parent 1: protocol ip u32 match u32 0 0 action mirred egress redirect dev ifb0
		
                tc qdisc add dev $DEVICE handle ffff: ingress
                tc filter add dev $DEVICE parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ifb1
        }
	
exit 0

