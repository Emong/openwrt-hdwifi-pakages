. /lib/ralink.sh
. /etc/openwrt_release
. /usr/share/libubox/jshn.sh


get_lan_mac() {

         [ "$(ralink_board_name)" = "mt7620a-evb" ] && local lan_mac=$(cat /sys/class/net/eth2/address)
         echo $lan_mac | awk -F : '{print $1$2$3$4$5$6}'
}

get_conf(){
        [ "$1" = "" ] && {
                echo "not give host!"
                exit 1
        }
        broad=$(ralink_board_name)
        uri="/yunwifi/wifi/getconf.action"
        host="http://${1}"
        url="${host}${uri}?model=${broad}&mac=$(get_lan_mac)"
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
