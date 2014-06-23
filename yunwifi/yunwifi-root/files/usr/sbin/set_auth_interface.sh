. /lib/ralink.sh
board=$(ralink_board_name)
wifi_auth_only() {
	lan_mac=$(cat /sys/class/net/eth2/address)
	dmz_mac=$(/usr/sbin/maccalc add "$lan_mac" -1)
    uci set network.dmz=interface
    uci set network.dmz.ifname=eth2.1
    uci set network.dmz.proto=static
	uci set network.dmz.macaddr=$dmz_mac
    uci set network.dmz.ipaddr=192.168.254.1
    uci set network.dmz.netmask=255.255.255.0
    uci set firewall.@zone[0].network='lan dmz'
    uci set network.lan.ifname=eth2.10
    uci set dhcp.dmz=dhcp
    uci set dhcp.dmz.interface=dmz
    uci set dhcp.dmz.leasetime=30m
    uci set dhcp.dmz.limit=150
    uci set dhcp.dmz.start=100
}
both_auth() {
    uci delete network.dmz
    uci delete dhcp.dmz
    uci set firewall.@zone[0].network='lan'
    uci set network.lan.ifname=eth2.1    
}

authtype=$(uci get yunwifi.config.authtype)
#if [ "$authtype" = "1" -a "$board" = "mt7620a-evb" ]
if [ "$board" = "mt7620a-evb" -o "$board" = "yunwifiv1" -o "$board" = "hc5661" ]
then
    uci get network.dmz
    [ "$?" != "0" ] && {
        logger "YUNWIFI:wifi auth only mode."
        wifi_auth_only
        uci commit
    }
else
    uci get network.dmz
    [ "$?" = "0" ] && {
        logger "YUNWIFI:hoth auth on lan and wlan interface mode."
        both_auth
        uci commit
    }
fi
