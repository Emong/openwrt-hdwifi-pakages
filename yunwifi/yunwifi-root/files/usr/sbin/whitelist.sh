#!/bin/sh
. /lib/hdwifi.sh

isip() {
	echo $1 | awk -F'.' '{if($1<=255&&$1>0&&$2<=255&&$2>=0&&$3<=255&&$3>=0&&$4<=255&&$4>=0){exit 1 }else {exit 0}}'
}


add_ipset() {
	ipset -N WHITE nethash --hashsize 5000 --probes 2
	iptables -t mangle -N YUNWIFI_white
	iptables -t mangle -F YUNWIFI_white
	iptables -t mangle -D PREROUTING -i br-lan -j YUNWIFI_white
	iptables -t mangle -A PREROUTING -i br-lan -j YUNWIFI_white
	iptables -t mangle -A YUNWIFI_white -p tcp -m multiport --dports 80,443 -m set --match-set WHITE dst -j MARK --set-mark 0x2

}
get_whitelist() {
	local host=$(uci get yunwifi.config.hostname)
	[ "$host" = "" ] && host=192.168.1.66
	local url=https://${host}/yunwifi/wifi/getwhitelist.action?gw_id=$(hdwifi_get_str)
	wget -qO /tmp/white.list --no-check-certificate $url
	while [ "$?" != "0" ]
	do
		logger -t HDWIFI:whitelist download list Error! Retry after 5s
		sleep 5
		wget -qO /tmp/white.list --no-check-certificate $url
	done
}
update_ipset() {
	logger "update is depressed"
}
update_with_dnsmasq(){
	logger -t HDWIFI:whitelist download whitelest from central server.
	get_whitelist
	rm /tmp/etc/dnsmasq.d/hdwifi-white.conf
	ipset flush WHITE
	cp /tmp/white.list /tmp/white.mixed.list
	cat /etc/wifidog.conf |grep Hostname |grep -v "#" |awk '{print $2}' >>/tmp/white.mixed.list
	local domain
	local ips
	local ip
	for domain in $(cat /tmp/white.mixed.list)
	do
		isip $domain
		if [ $? -eq 1 ];then
			ipset -A WHITE $domain
		else
			echo $domain | awk '{print "ipset=/" $0 "/WHITE"}' >>/tmp/etc/dnsmasq.d/hdwifi-white.conf                               
		fi
	done
	dnsmasq --test || rm /tmp/etc/dnsmasq.d/hdwifi-white.conf
	/etc/init.d/dnsmasq restart
}
case "$1" in
	"do_table")
		add_ipset
		;;
	"update")
		update_ipset
		;;
	"update-with-dnsmasq")
		update_with_dnsmasq
		;;
	"start")
		add_ipset
		update_with_dnsmasq &
		;;
	*)
		echo "No such Function!"
		;;
esac


