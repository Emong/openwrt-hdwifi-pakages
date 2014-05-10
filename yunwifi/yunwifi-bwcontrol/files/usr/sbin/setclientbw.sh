IP=$1
IP=$(echo $1 | awk -F . '{print $4}')
HIP=$1
DOWNRATE=$2
UPRATE=$3
isin=$(tc class show dev ifb0 classid 1:$IP)
[ "$isin" = "" ] && {
	tc class add dev ifb0 parent 1: classid 1:$IP htb rate ${DOWNRATE}kbit
	tc qdisc add dev ifb0 parent 1:$IP handle $IP sfq perturb 10
	tc filter add dev ifb0 protocol ip prio 1 u32 match ip dst $HIP flowid 1:$IP
	
	tc class add dev ifb1 parent 1: classid 1:$IP htb rate ${UPRATE}kbit
	tc qdisc add dev ifb1 parent 1:$IP handle $IP sfq perturb 10
	tc filter add dev ifb1 protocol ip prio 1 u32 match ip src $HIP flowid 1:$IP

	exit 0
}
echo "has done! only reset bandwidth"
tc class ch dev ifb0 parent 1: classid 1:$IP htb rate ${DOWNRATE}kbit
tc class ch dev ifb1 parent 1: classid 1:$IP htb rate ${UPRATE}kbit
exit 0
