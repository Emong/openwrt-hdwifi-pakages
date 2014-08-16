#!/bin/sh
i=0
while true
do
	[ $(ps |grep wifidog |wc -l) -lt 2 ] &&
	{
		echo "No dog !start it"
		wifidog
		i=0
	}
	let i=$i+1
	[ $i -ge 288 ] && 
	{
		wdctl restart
		i=0
	}
	sleep 300
done
