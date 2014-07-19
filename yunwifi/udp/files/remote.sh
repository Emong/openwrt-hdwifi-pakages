#!/bin/sh
[ "$1" = "start" -a "$2" != "" ] && {
	proc_autossh="/proc/$(cat /tmp/run/autossh.pid 2>/dev/null)/status"
	#echo $proc_autossh
	[ -e $proc_autossh ] && {
		echo "Has Opened:$(cat /tmp/nat_port.txt)"
		exit 1
	}

	nat_port=$2
	ssh_port=$(uci get dropbear.@dropbear[0].Port)
	[ "$ssh_port" = "" ] && ssh_port=8022
	AUTOSSH_GATETIME="30" \
	AUTOSSH_POLL="600" \
	HOME="/root" \
	AUTOSSH_PIDFILE="/tmp/run/autossh.pid" \
	/usr/sbin/autossh -M 0 -f -i /etc/dropbear/hdwifi-router -y -N -T -R $nat_port:localhost:$ssh_port -R $(expr $nat_port + 1):localhost:80 hdwifi@hdwifi-nat.emong.me
	echo $nat_port > /tmp/nat_port.txt
	echo "New Opened:$nat_port"
}
[ "$1" = "stop" ] && {
	kill $(cat /tmp/run/autossh.pid 2>/dev/null) 2>/dev/null
	if [ "$?" = "0" ]
	then
		echo Ok
	else
		echo fail
	fi
#rm /tmp/run/autossh.pid
}

