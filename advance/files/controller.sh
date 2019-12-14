#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh

ip_public(){
	PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
	#echo $PUBLIC_IP
}

meshdesk(){
	dnsctl=$(uci -q get meshdesk.internet1.dns)
	ip=`nslookup $dnsctl | grep 'Address' | grep -v '127.0.0.1' | grep -v '8.8.8.8' | grep -v '0.0.0.0'|grep -v '::' | awk '{print $3}'`
	if [ "$ip" != "" ] &&  [ -e /etc/config/meshdesk ];then
		uci set meshdesk.internet1.ip=$ip
		uci commit meshdesk
	fi
}

checking (){
	#Clear memory
	if [ "$(cat /proc/meminfo | grep 'MemFree:' | awk '{print $2}')" -lt 5000 ]; then
		echo "Clear Cach"
		free && sync && echo 3 > /proc/sys/vm/drop_caches && free
	fi
	source /lib/functions/network.sh ; if network_get_ipaddr addr "wan"; then echo "WAN: $addr" >/tmp/ipaddr; fi
	#pidhostapd=`pidof hostapd`
	#if [ -z $pidhostapd ];then echo "Wireless Off" >/tmp/wirelessstatus;else echo "Wireless On" >/tmp/wirelessstatus;fi
}

##Sent Client MAC to server Nextify
get_client_connect_wlan(){
	_openvpn=`pidof openvpn`
	if [ -n "$_openvpn" ];then
		ip_opvn=`ifconfig tun0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`
	fi
	local _url=$1
	NEWLINE_IFS='
'
	OLD_IFS="$IFS"; IFS=$NEWLINE_IFS
	signal=''
	host=''
	mac=''
	touch /tmp/client_connect_wlan
	for iface in `iw dev | grep Interface | awk '{print $2}'`; do
		for line in `iwinfo $iface assoclist`; do
			if echo "$line" | grep -q "SNR"; then
				if [ -f /etc/ethers ]; then
					mac=$(echo $line | awk '{print $1}' FS=" ")
					host=$(awk -v MAC=$mac 'tolower($1)==MAC {print $1}' FS=" " /etc/ethers)
					data=";$mac"
					echo $data >>/tmp/client_connect_wlan
				fi
			fi
		done
	done
	IFS="$OLD_IFS"
	client_connect_wlan=$(cat /tmp/client_connect_wlan | xargs| sed 's/;/ /g'| tr a-z A-Z)
	number_client=$(cat /tmp/client_connect_wlan | wc -l)
	#monitor_port
	#wget --post-data="&access_point_macs=${global_device}&mac_clients=${client_connect_wlan}&clients=${clients}&ip_opvn=${ip_opvn}" https://api.telitads.vn/v1/access_points/state -O /dev/null #https://api.telitads.vn/v1/access_points/state
	wget --post-data="&access_point_macs=${global_device}&mac_clients=${client_connect_wlan}" https://api-dev.telitads.vn/v1/splash/connect -O /dev/null
	echo $client_connect_wlan
	rm /tmp/client_connect_wlan
}

action_lan_wlan(){
	echo "" > $find_mac_gateway
	wget -q "${blacklist}" -O $find_mac_gateway
	curl_result=$?
	if [ "${curl_result}" -eq 0 ]; then
		cat "$find_mac_gateway" | while read line ; do
			if [ "$(echo $line | grep $_device)" ] ;then
				wifi down
				ifdown lan
			fi
		done	
	fi
}

license_srv() {
	###MAC WAN:WR940NV6 --Ethernet0 OPENWRT19
	echo "" > $licensekey
	wget -q "${code_srv}" -O $licensekey
	curl_result=$?
	if [ "${curl_result}" -eq 0 ]; then
		if grep -q "." $licensekey; then
			cat "$licensekey" | while read line ; do
				if [ "$(echo $line | grep $_device)" ] ;then
					uci set wifimedia.@hash256[0].wfm="$(cat /etc/opt/license/wifimedia)"
					uci commit wifimedia
					cat /etc/opt/license/wifimedia >/etc/opt/license/status
					license_local
				else
					echo "0 0 * * * /sbin/wifimedia/controller.sh license_srv" > /etc/crontabs/wificode
				fi
			done	
		fi
	fi
}

license_local() {
	first_time=$(cat /etc/opt/first_time.txt)
	timenow=$(date +"%s")
	diff=$(expr $timenow - $first_time)
	days=$(expr $diff / 86400)
	diff=$(expr $diff \% 86400)
	hours=$(expr $diff / 3600)
	diff=$(expr $diff \% 3600)
	min=$(expr $diff / 60)

	#uptime="${days}"
	time=$(uci -q get wifimedia.@wireless[0].time)
	time1=${days}
	uptime="${time:-$time1}"
	#uptime="${$(uci get license.active.time):-${days}}"
	#uptime="${days}d:${hours}h:${min}m"
	status=/etc/opt/wfm_status
	lcs=/etc/opt/wfm_lcs
	if [ "$(uci -q get wifimedia.@hash256[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
		echo "Activated" >/etc/opt/license/status
		#touch $status
		echo "" >/etc/crontabs/wificode
		/etc/init.d/cron restart	
		rm $lcs
	else
		echo "Wrong License Code" >/etc/opt/license/status
	fi
	if [ "$uptime" -gt 15 ]; then #>15days
		if [ "$(uci -q get wifimedia.@hash256[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
			uci set wireless.radio0.disabled="0"
			uci set wireless.radio1.disabled="0"
			uci commit wireless
			wifi
			#touch $status
			rm $lcs
			echo "Activated" >/etc/opt/license/status
			echo "" >/etc/crontabs/wificode
			/etc/init.d/cron restart
		else
			echo "Wrong License Code" >/etc/opt/license/status
			uci set wireless.radio0.disabled="1"
			uci set wireless.radio1.disabled="1"
			uci commit wireless
			wifi down
		fi
	fi
}

rssi() {
if [ $rssi_on == "1" ];then
	level_defaults=-80
	level=$(uci -q get wifimedia.@wireless[0].level)
	level=${level%dBm}
	LOWER=${level:-$level_defaults}
	#echo $LOWER	
	dl_time=$(uci -q get wifimedia.@wireless[0].delays)
	dl_time=${dl_time%s}
	ban_time=$(expr $dl_time \* 1000)
	touch /tmp/denyclient
	chmod a+x /tmp/denyclient
	NEWLINE_IFS='
'
	OLD_IFS="$IFS"; IFS=$NEWLINE_IFS
	signal=''
	host=''
	mac=''

	for iface in `iw dev | grep Interface | awk '{print $2}'`; do
		for line in `iw $iface station dump`; do
			if echo "$line" | grep -q "Station"; then
				if [ -f /etc/ethers ]; then
					mac=$(echo $line | awk '{print $2}' FS=" ")
					host=$(awk -v MAC=$mac 'tolower($1)==MAC {print $2}' FS=" " /etc/ethers)
				fi
			fi
			if echo "$line" | grep -q "signal:"; then
				signal=`echo "$line" | awk '{print $2}'`
				#echo "$mac (on $iface) $signal $host"
				if [ "$signal" -lt "$LOWER" ]; then
					#echo $MAC IS $SNR - LOWER THAN $LOWER DEAUTH THEM
					echo "ubus call hostapd.$iface "del_client" '{\"addr\":\"$mac\", \"reason\": 1, \"deauth\": True, \"ban_time\": $ban_time}'" >>/tmp/denyclient
				fi
			fi
		done
	done
	IFS="$OLD_IFS"
	/tmp/denyclient
	echo "#!/bin/sh" >/tmp/denyclient
fi #END RSSI

}

heartbeat(){
	MAC=$(ifconfig eth0 | grep 'HWaddr' | awk '{ print $5 }')
	UPTIME=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
	RAM_FREE=$(grep -i 'MemFree:'  /proc/meminfo | cut -d':' -f2 | xargs)
	wget --post-data="&access_point_macs=${global_device}&uptime=${UPTIME}&ram_free=${RAM_FREE}" https://api.telitads.vn/v1/access_points/state -O /dev/null #https://api.telitads.vn/v1/access_points/state
}

openvpn(){
cfg_ovpn=/etc/openvpn/wifimedia.ovpn
srv_ovpn="http://openvpn.wifimedia.vn/$_device.ovpn"
certificate=wifimedia
uci -q get openvpn.@$certificate[0] || {
uci batch <<-EOF
	add openvpn $certificate
	set openvpn.${certificate}=openvpn
	set openvpn.${certificate}.config="$cfg_ovpn"
	set openvpn.${certificate}.enabled="1"
	commit openvpn
EOF
}

	wget -q "${srv_ovpn}" -O $cfg_ovpn
	curl_result=$?
	if [ "${curl_result}" -eq 0 ]; then
		uci set openvpn.${certificate}.enabled="1"
		uci commit openvpn
		/etc/init.d/openvpn start ${certificate}
	else
		uci set openvpn.${certificate}.enabled="1"
		uci commit openvpn
		/etc/init.d/openvpn stop ${certificate}
	fi
}

"$@"
