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
        local url=http://${host}/yunwifi/wifi/getwhitelist.action
        wget -qO /tmp/white.list $url
        [ "$?" != "0" ] && {
                logger "YUNWIFI:whitelist:download list Error!"
                exit 1
        }
}
update_ipset() {
        [ ! -f /tmp/white.list ] && {
                logger  "YUNWIFI:whitelist:No list avaliable, download from remote server."
                get_whitelist
        }
        local domain
        local ips
        local ip
        for domain in $(cat /tmp/white.list)
        do
                ips=$(resolveip -4 -t 10 $domain)
                for ip in $(resolveip -4 -t 10 $domain)
                do
                        ipset test WHITE $ip 2>/dev/null
                        [ "$?" != "0" ] && {
                                ipset -A WHITE $ip
                        }
                done
        done
}
case "$1" in
        "do_table")
                add_ipset
                ;;
        "update")
                update_ipset
                ;;
        *)
                echo "No such Function!"
                ;;
esac


