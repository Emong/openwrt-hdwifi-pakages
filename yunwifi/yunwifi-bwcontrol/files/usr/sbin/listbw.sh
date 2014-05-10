#!/bin/sh
echo "DownLoad Qos"
tc cl show dev ifb0 |grep htb |awk '{print "192.168.1."$6" " $10 "    "}'

echo "UpLoad Qos"
tc cl show dev ifb1 |grep htb |awk '{print "192.168.1."$6" " $10 "    "}'
