. /lib/ralink.sh
. /etc/openwrt_release
. /usr/share/libubox/jshn.sh

get_host_from_wifidog() {
        local host=$(uci get yunwifi.config.hostname)
        [ "$host" = "" ] && host=192.168.1.66
        echo $host
}
do_update() {
        local url=$1
        local md5=$2
        [ "$url" = "" ] && {
            logger "autograde:Current Version is update!!"        
            exit 1
        }
        wget -O /tmp/update.bin $url
        [ "$?" != "0" ] && exit 1
        local file_md5=$(md5sum /tmp/update.bin |awk '{print $1}')
        [ "$file_md5" = "$md5" ] && {
                sysupgrade /tmp/update.bin
        }
}

check_up(){
        broad=$(ralink_board_name)
        uri="/yunwifi/wifi/getupdinfo.action"
        host="http://$(get_host_from_wifidog)"
        url="${host}${uri}?aptype=${broad}&currentversion=${DISTRIB_VERSION}"
#       echo $url
        local JSON=$(wget -qO - $url)
        [ "$?" != "0" ] && {
            logger "YUNWIFI:autoupgrade json get fail!"            
            exit 1
        }
        eval $(jshn -r $JSON)
#       echo $JSON_VAR_url
#       echo $JSON_VAR_md5
        do_update $JSON_VAR_url $JSON_VAR_md5

        exit 0

}
check_up
