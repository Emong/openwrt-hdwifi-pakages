#!/bin/sh
# Copyright (C) 2014 Emong
# http://blog.emong.me

cblock_num=$(tc cl show dev ifb0 |grep htb |awk '{print $6 }' |cut -c 3-4 | sort -n | uniq | wc -l)
if [ $cblock_num -ge 2 ]
then
	prefix=$(uci get network.lan.ipaddr |awk -F . '{print $1"."$2"."}')
	[ "$prefix" = "" ] && prefix="192.168."
	echo "DownLoad Qos"
	tc cl show dev ifb0 |grep htb |awk '{print "0x" $6 " " $10 }' |awk '{printf("'$prefix'%d.%d",$1%256,$1/256);print " "$2}'

	echo "UpLoad Qos"
	tc cl show dev ifb1 |grep htb |awk '{print "0x" $6 " " $10 }' |awk '{printf("'$prefix'%d.%d",$1%256,$1/256);print " "$2}'

else
	prefix=$(uci get network.lan.ipaddr |awk -F . '{print $1"."$2"."$3"."}')
	[ "$prefix" = "" ] && prefix="192.168.1."
	echo "DownLoad Qos"
	tc cl show dev ifb0 |grep htb |awk '{print "0x" $6 " " $10 }' |awk '{printf("'$prefix'%d",$1/256);printf("/%d",$1%256);print " "$2}'

	echo "UpLoad Qos"
	tc cl show dev ifb1 |grep htb |awk '{print "0x" $6 " " $10 }' |awk '{printf("'$prefix'%d",$1/256);printf("/%d",$1%256);print " "$2}'
fi

