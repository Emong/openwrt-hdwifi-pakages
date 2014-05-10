awk '{
if(/local keepalive/){
	print "\t[ -f /usr/bin/ghcadia ] && \{\n"\
	"\t\tlocal ghcat\n"\
	"\t\tconfig_get ghcat \"$cfg\" ghcat\n"\
	"\t\tlogger \"PPPoE with GHCACalculator!\"\n"\
	"\t\tusername=$(ghcadia $username $password $ghcat)\n"\
	"\t\tlogger \"GHCACalculator Done!\"\n"\
	"\t\tlogger \"Dial username:$username\"\n"\
	"\t\}\n\n"\
	$0
}
else
	print $0
}'
