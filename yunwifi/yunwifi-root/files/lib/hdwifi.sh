#!/bin/sh
#
# Copyright (C) 2014 emongxx@gmail.com
#

local PLAT=x86

[ -f /lib/ralink.sh ] && {
	PLAT=ralink
	. /lib/ralink.sh
}

hdwifi_get_board() {
	case "$PLAT" in
	"x86")
		echo x86
	;;
	"ralink")
		ralink_board_name
	;;
	esac
}

hdwifi_get_str() {
	case "$PLAT" in
	"x86")
		x86
	;;
	"ralink")
		ralink_set_yunwifi_str $@
	;;
	esac
}
hdwifi_set_str() {
	case "$PLAT" in
	"x86")
		 x86
	;;
	"ralink")
		ralink_set_yunwifi_str $@
	;;
	esac

}
hdwifi_clear_str() {
	case "$PLAT" in
	"x86")
		x86
	;;
	"ralink")
		ralink_set_yunwifi_str $@
	;;
	esac
}
