. /lib/ralink.sh
board=$(ralink_board_name)
wifi_auth_only() {
    uci set network.wln=interface
    uci set network.wln.ifname=eth2.1
    uci set network.wln.proto=static
    uci set network.wln.ipaddr=192.168.254.1
    uci set network.wln.netmask=255.255.255.0
    uci set firewall.@zone[0].network='lan wln'
    uci set network.lan.ifname=eth2.10
    uci set dhcp.wln=dhcp
    uci set dhcp.wln.interface=wln
    uci set dhcp.wln.leasetime=30m
    uci set dhcp.wln.limit=150
    uci set dhcp.wln.start=100
}
both_auth() {
    uci delete network.wln
    uci delete dhcp.wln
    uci set firewall.@zone[0].network='lan'
    uci set network.lan.ifname=eth2.1    
}

authtype=$(uci get yunwifi.config.authtype)
#if [ "$authtype" = "1" -a "$board" = "mt7620a-evb" ]
if [ "$board" = "mt7620a-evb" -o "$board" = "yunwifiv1" ]
then
    uci get network.wln
    [ "$?" != "0" ] && {
        logger "YUNWIFI:wifi auth only mode."
        wifi_auth_only
        uci commit
    }
else
    uci get network.wln
    [ "$?" = "0" ] && {
        logger "YUNWIFI:hoth auth on lan and wlan interface mode."
        both_auth
        uci commit
    }
fi
