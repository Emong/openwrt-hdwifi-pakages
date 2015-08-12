#!/bin/sh
sleep 60
while true
do
	[ ! -e /tmp/dog-startat ] && cat /proc/uptime |awk '{printf("%d\n",$1)}' >/tmp/dog-startat
	pidof wifidog || pidof get_wifidog_conf.sh || 
	{
		logger -t check_dog No dog !start it
		wifidog
		cat /proc/uptime |awk '{printf("%d\n",$1)}' >/tmp/dog-startat
	}
	dogstart=$(cat /tmp/dog-startat)
	udphdstatus=$(cat /tmp/udphd-status)
	dognow=$(cat /proc/uptime |awk '{printf("%d\n",$1)}')
	[ $(($dognow - $dogstart)) -ge 86400 ] && 
	{
		wdctl restart
		/etc/init.d/uhttpd restart
		/etc/init.d/dnsmasq restart
		[ "$?" = "0" ] && cat /proc/uptime |awk '{printf("%d\n",$1)}' >/tmp/dog-startat
	}
	[ $(($dognow - $udphdstatus)) -ge 300 ] && 
	{
		/etc/init.d/udphd restart
		logger -t check_dog udphd seems not travel,restart it
	}
	sleep 300
done
