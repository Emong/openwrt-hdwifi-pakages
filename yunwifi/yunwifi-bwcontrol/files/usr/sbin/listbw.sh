#!/bin/sh

prefix=$(uci get network.lan.ipaddr |awk -F . '{print $1"."$2"."$3"."}')
[ "$prefix" = "" ] && prefix="192.168.1."

echo "DownLoad Qos"
tc cl show dev ifb0 |grep htb |awk '{print "'$prefix'"$6" " $10 "    "}'

echo "UpLoad Qos"
tc cl show dev ifb1 |grep htb |awk '{print "'$prefix'"$6" " $10 "    "}'

