#!/bin/sh
local internet_led=internet
internet_up() {
	local wan_if=$(ip ro |grep default |awk -F 'dev' '{print $2}' |awk '{print $1}')
	[ "$wan_if" = "" ]&& wan_if=eth2.2
	echo netdev >/sys/class/leds/${internet_led}/trigger
	echo $wan_if > /sys/class/leds/${internet_led}/device_name
	echo "link tx" > /sys/class/leds/${internet_led}/mode

}
internet_down() {
	echo none >/sys/class/leds/${internet_led}/trigger
}
get_state() {
	local state=0
	[ -e /tmp/wan_up_state ] && state=1
	echo $state
}
set_state() {
	if [ "$1" = "up" ]
	then
		touch /tmp/wan_up_state
	else
		rm /tmp/wan_up_state
	fi
}
check_wan() {
	local last_state=$(get_state)
#	echo $last_state
	local internet_on=0
	ping -w 2 -c 1 114.114.114.114 >/dev/null 2>&1 || ping -w 2 -c 1 223.5.5.5 >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		[ "$last_state" != "1" ] && {
			internet_up
			set_state up
		}
	else
		[ "$last_state" != "0" ] && {
			internet_down
			set_state down
		}
	fi
}
. /lib/ralink.sh

board=$(ralink_board_name)

if [ "${board}" == "hc5661" ]; then
	while [ 1 -eq 1 ]
	do
		    check_wan
		    sleep 5
	done
fi

