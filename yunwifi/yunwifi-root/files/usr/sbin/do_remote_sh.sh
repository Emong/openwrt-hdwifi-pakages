check_host() {
	[ "$1" != "cmd.emong.me" ] && {
                echo "not support the host for security reason"
                exit 1
        }
        return 0
}
get_script() {
        local host=$1
        local uri=$2
        local url=http://${host}${uri}
        wget -qO /tmp/remote_script.sh $url
        [ "$?" != "0" ] && {
                echo "can't download"
                exit 1
        }
}
do_script() {
        head -1 /tmp/remote_script.sh |grep -q "#!/bin/sh"
        [ "$?" != "0" ] && {
                echo "script error"
                exit 1
        }
        sh /tmp/remote_script.sh
}
check_host $1
get_script $@
do_script