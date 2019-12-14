#!/bin/sh
#Copyright ©  dungtd8x@gmail.com

first_time=$(cat /etc/opt/first_time.txt)
timenow=$(date +"%s")

diff=$(expr $timenow - $first_time)
days=$(expr $diff / 86400)
diff=$(expr $diff \% 86400)
hours=$(expr $diff / 3600)
diff=$(expr $diff \% 3600)
min=$(expr $diff / 60)

#uptime="${days}"
time=$(uci -q get wifimedia.@advance[0].time)
time1=${days}
uptime="${time:-$time1}"
#uptime="${$(uci get license.active.time):-${days}}"
#uptime="${days}d:${hours}h:${min}m"
status=/etc/opt/wfm_status
lcs=/etc/opt/wfm_lcs
if [ "$(uci -q get wifimedia.@advance[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
	cat /etc/opt/license/wifimedia >/etc/opt/license/status
	touch $status
	rm $lcs
else
	echo "Wrong License Code & Auto Reboot" >/etc/opt/license/status
fi
if [ "$uptime" -gt 15 ]; then #>15days
	if [ "$(uci -q get wifimedia.@advance[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
		touch $status
		rm $lcs
		cat /etc/opt/license/wifimedia >/etc/opt/license/status
	else
		echo "Wrong License Code & Auto Reboot" >/etc/opt/license/status
		rm $status
	fi
fi
