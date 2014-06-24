#!/bin/sh
ch_mac() {
	old=$(dd bs=1 count=6 skip=40 if=/dev/mtd2 |maccalc bin2mac |awk -F : '{print $1$2$3}')
	if [ "$old" = "000c43" ]
	then
		now_mac=$(dd bs=1 count=17 skip=394 if=/dev/mtd9 2>/dev/null)
		now_mac=$(echo $now_mac |tr '[A-Z]' '[a-z]')
		ralink_ch_mac $now_mac
	fi
}

. /lib/ralink.sh

board=$(ralink_board_name)

if [ "${board}" == "hc5661" ]; then
	ch_mac
	[ -e /etc/rc.d/S11hc5661-mac ] && rm /etc/rc.d/S11hc5661-mac
fi

