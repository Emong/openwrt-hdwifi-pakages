#!/bin/sh
#
# Copyright (C) 2014 emongxx@gmail.com
#

local PLAT=x86

[ -f /lib/x86.sh ] && {
	PLAT=x86
	. /lib/x86.sh
}

[ -f /lib/ralink.sh ] && {
	PLAT=ralink
	. /lib/ralink.sh
}

hdwifi_get_board() {
	case "$PLAT" in
	"x86")
		x86_board_name
	;;
	"ralink")
		ralink_board_name
	;;
	esac
}

hdwifi_get_str() {
	case "$PLAT" in
	"x86")
		x86_get_yunwifi_str $@
	;;
	"ralink")
		ralink_get_yunwifi_str $@
	;;
	esac
}
hdwifi_set_str() {
	case "$PLAT" in
	"x86")
		 x86_set_yunwifi_str $@
	;;
	"ralink")
		ralink_set_yunwifi_str $@
	;;
	esac

}
hdwifi_clear_str() {
	case "$PLAT" in
	"x86")
		x86_clear_yunwifistr $@
	;;
	"ralink")
		ralink_clear_yunwifistr $@
	;;
	esac
}
hdwifi_get_mac() {
	case "$PLAT" in
	"x86")
		cat /sys/class/net/eth0/address
	;;
	"ralink")
		cat /sys/class/net/eth2/address
	;;
	esac
}
