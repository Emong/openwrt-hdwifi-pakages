#!/bin/sh
# Copyright (C) 2014 Emong
# http://blog.emong.me

tc qdisc del dev ifb0 root
tc qdisc add dev ifb0 root handle 1: htb

tc qdisc del dev ifb1 root
tc qdisc add dev ifb1 root handle 1: htb

