. /etc/openwrt_release
. /usr/share/libubox/jshn.sh
local board
local yunwifi_str
local domain=$1

get_lan_mac() {

         [ "$(ralink_board_name)" = "mt7620a-evb" ] && local lan_mac=$(cat /sys/class/net/eth2/address)
         echo $lan_mac | awk -F : '{print $1$2$3$4$5$6}'
}
set_yunwifi_str() {
	[ -e /tmp/lock/yunwifi_str.lck ] && {
		echo "has run!"
		return 1
	}
	touch /tmp/lock/yunwifi_str.lck
	local url="http://${domain}/getyunwifistr.action"
	wget -qO /tmp/yunwifi_str.txt $url
	while [ "$?" != "0" ]
	do
		sleep 5
		wget -qO /tmp/yunwifi_str.txt $url
	done
	local str=$(cat /tmp/yunwifi_str.txt)
	url="http://${domain}/confirmyunwifistr.action?${str}"
	[ -f /lib/ralink.sh ] && {		
		ralink_set_yunwifi_str $str
		[ "$?" = "0" ] && {
			wget -qO /dev/null $url
			while [ "$?" != "0" ]
			do
				sleep 5
				wget -qO /dev/null $url
			done
		}
	}
	rm /tmp/lock/yunwifi_str.lck
}
get_yunwifi_str() {
	[ -f /lib/ralink.sh ] && {
		. /lib/ralink.sh
		board=$(ralink_board_name)
		yunwifi_str=$(ralink_get_yunwifi_str)
		[ "$?" != "0" ] && {
			echo "not set yunwifi str get from server"
			set_yunwifi_str
		}
	}
	[ -f /lib/ar71xx.sh ] && {
		. /lib/ar71xx.sh
		board=$(ar71xx_board_name)
		yunwifi_str=$(ar71xx_get_yunwifi_str)
		[ "$?" != "0" ] && {
			echo "not set yunwifi str get from server"
			set_yunwifi_str
		}
	}
}

get_conf(){
        [ "$1" = "" ] && {
                echo "not give host!"
                exit 1
        }
		get_yunwifi_str
        uri="/yunwifi/wifi/getconf.action"
        host="http://${1}"
        url="${host}${uri}?aptype=${board}&yunwifistr=${yunwifi_str}"
        wget -qO /tmp/wifidog.conf $url
        [ "$?" != "0" ] && {
            logger "YUNWIFI:wifidog remote config fail!"            
            exit 1
        }
        sed -i 's/\r//' /tmp/wifidog.conf
        newdog_md5=$(md5sum /tmp/wifidog.conf |awk '{print $1}')
        olddog_md5=$(md5sum /etc/wifidog.conf |awk '{print $1}')
        [ "$newdog_md5" != "" -a "$olddog_md5" != "" -a "$newdog_md5" = "$olddog_md5" ] && {
                logger "YUNWIFI:remote wifidog conf same ! do nothing!!"
                exit 0
        }
        cp /tmp/wifidog.conf /etc/wifidog.conf
        wdctl restart
        [ "$?" != "0" ] && wifidog

        exit 0
}
get_conf $1
