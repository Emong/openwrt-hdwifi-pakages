#!/bin/sh
while true
do
	[ $(ps |grep wifidog |wc -l) -lt 2 ] &&
	{
		echo "No dog !start it"
		wifidog
	}
	sleep 300
done
