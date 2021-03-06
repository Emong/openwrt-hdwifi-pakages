#!/bin/sh
. /etc/openwrt_release
. /usr/share/libubox/jshn.sh
. /lib/hdwifi.sh
local board=$(hdwifi_get_board)
local yunwifi_str
local domain=$(uci get yunwifi.config.hostname)

set_yunwifi_str() {
	[ -e /tmp/lock/yunwifi_str.lck ] && {
		echo "has run!"
		return 1
	}
	touch /tmp/lock/yunwifi_str.lck
	local url="https://${domain}/yunwifi/wifi/getyunwifistr.action"
	wget -qO /tmp/yunwifi_str.txt --no-check-certificate $url
	while [ "$?" != "0" ]
	do
		sleep 5
		wget -qO /tmp/yunwifi_str.txt --no-check-certificate $url
	done
	local str=$(cat /tmp/yunwifi_str.txt)
	yunwifi_str=$(cat /tmp/yunwifi_str.txt)
	local mac=$(hdwifi_get_mac)
	url="https://${domain}/yunwifi/wifi/confirmyunwifistr.action?gw_id=${str}&mac=${mac}&aptype="
	url=${url}$(hdwifi_get_board)
	hdwifi_set_str $yunwifi_str
	[ "$?" = "0" ] && {
		wget -qO /dev/null --no-check-certificate $url
		while [ "$?" != "0" ]
		do
			sleep 5
			wget -qO /dev/null --no-check-certificate $url
		done
	}
	rm /tmp/lock/yunwifi_str.lck
}
get_yunwifi_str() {

	yunwifi_str=$(hdwifi_get_str)
	[ "$?" != "0" ] && {
		echo "not set yunwifi str get from server"
		set_yunwifi_str
	}
}

get_conf_remote(){
	# get_conf_remote  $host $only_download
        [ "$1" = "" ] && {
                echo "not give host!"
                exit 1
        }
		get_yunwifi_str
        uri="/yunwifi/wifi/getconf.action"
        host="https://${1}"
        url="${host}${uri}?aptype=${board}&gw_id=${yunwifi_str}&currentversion=${DISTRIB_VERSION}"
        wget -qO /tmp/wifidog.conf --no-check-certificate $url
        while [ "$?" != "0" ]
		do
            sleep 5
			wget -qO /tmp/wifidog.conf --no-check-certificate $url
        done
        sed -i 's/\r//' /tmp/wifidog.conf
        [ "$2" == 1 ] && return 0
        newdog_md5=$(md5sum /tmp/wifidog.conf |awk '{print $1}')
        olddog_md5=$(md5sum /etc/wifidog.conf |awk '{print $1}')
		is_wifidog_conf=$(cat /tmp/wifidog.conf |grep GatewayID)
        [ "$newdog_md5" != "" -a "$olddog_md5" != "" -a "$newdog_md5" = "$olddog_md5" ] && {
                logger "YUNWIFI:remote wifidog conf same ! do nothing!!"
				[ -z "$(pidof wifidog)" ] &&
				{
					logger "No dog !start it"
					wifidog
				}
                exit 0
        }
        [ "$is_wifidog_conf" != "" ] && cp /tmp/wifidog.conf /etc/wifidog.conf
        wdctl restart
        [ "$?" != "0" ] && wifidog

        return 0
}
get_conf_local() {
	local down_bw=$(uci get yunwifi.config.download_bw || echo 10240)
	local up_bw=$(uci get yunwifi.config.up_bw || echo 10240)
	cat /tmp/wifidog.conf |grep -q ClientBandwidthDown && down_bw=$(cat /tmp/wifidog.conf |grep ClientBandwidthDown |awk '{print $2}')
	cat /tmp/wifidog.conf |grep -q ClientBandwidthUp && up_bw=$(cat /tmp/wifidog.conf |grep ClientBandwidthUp |awk '{print $2}')
	local lan_ip=$(uci get network.lan.ipaddr || echo 192.168.253.1)
	local gw_id=$(hdwifi_get_str)

	sed -e "s#|gw_id|#$gw_id#g" \
		-e "s#|auth_server|#$lan_ip#g" \
		-e "s#|up_bw|#$up_bw#g" \
		-e "s#|down_bw|#$down_bw#g" \
		-e "s#|central_server|#$domain#g" \
		/etc/wifidog.conf.template >/etc/wifidog.conf

	ip ro |grep default || ip ro add default dev lo metric 1024
	wdctl restart || wifidog
	return 0
}
get_pages() {
	local gw_id=$(hdwifi_get_str)
	local url="https://${domain}/yunwifi/wifi/getlocalloginzip.action?gw_id=${gw_id}"
	local JSON
	JSON=$(wget --no-check-certificate -qO - $url)
	while [ "$?" != "0" ]
	do
		sleep 5
		JSON=$(wget --no-check-certificate -qO - $url)
	done
	eval $(jshn -r $JSON)
	[ "$JSON_VAR_url" == "" ] && JSON_VAR_url="http://wifi.myhdit.com/yunwifi/jsp/localLoginUrl/408/yunwifi/wifi.zip"
	wget --no-check-certificate -qO /tmp/pages.zip $JSON_VAR_url
	while [ "$?" != "0" ]
	do
		sleep 5
		wget --no-check-certificate -qO /tmp/pages.zip $JSON_VAR_url
	done
	unzip -d /tmp/wwwroot/ /tmp/pages.zip >/dev/null 2>&1
}
get_conf() {
	local local_wifi=$(uci get yunwifi.config.local_wifi || echo 0)
	if [ "$local_wifi" == "0" ]
	then
		get_conf_remote $@
	else
		rm -fr /tmp/pages /tmp/wwwroot/*
		get_conf_remote $1 1
		get_conf_local
		rm -fr /tmp/wifidog.conf
		get_pages
	fi
}
if [ "$1" != "" ]
then
	get_conf $1 &
else
	local host=$(uci get yunwifi.config.hostname)
	get_conf $host &
fi
