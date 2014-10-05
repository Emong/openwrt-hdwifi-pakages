#!/bin/sh
merge_iptables() {
    awk '{a[$1]=a[$1]?a[$1]FS$2:$2}END{for(i in a)print i,a[i]}'
}

get_iptables() {
    interval=$1
    [ -z "$interval" ] && interval=1
    iptables -t mangle -nvxL WiFiDog_br-lan_Outgoing |grep MARK |awk '{print $8" "$11}'
    iptables -t mangle -nvxL WiFiDog_br-lan_Incoming |grep ACCEPT |awk '{print $9" "$2}'
    iptables -t mangle -nvxL WiFiDog_br-lan_Outgoing |grep MARK |awk '{print $8" "$2}'
    sleep $interval
    iptables -t mangle -nvxL WiFiDog_br-lan_Incoming |grep ACCEPT |awk '{print $9" "$2}'
    iptables -t mangle -nvxL WiFiDog_br-lan_Outgoing |grep MARK |awk '{print $8" "$2}'
}
cal_bw() {
    interval=$1
    [ -z "$interval" ] && interval=1
    get_iptables $interval  | merge_iptables |awk '{print $1" "$2" "($5-$3)/1024/"'$interval'" " " ($6-$4)/1024/"'$interval'"}'
}
cal_bw $@

