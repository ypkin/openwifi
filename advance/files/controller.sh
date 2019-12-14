#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh

ip_dhcp=$(ifconfig br-wan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
ip_lan_gw=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
ip_gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')

ip_public(){
	PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
	#echo $PUBLIC_IP
}
wr840v4() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wps/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wps/
		echo none > trigger
	fi

	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wan/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wan/
		echo none > trigger
	fi
}

wr840v620() { #checking internet

	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		echo none >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/trigger
		echo timer >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wlan/trigger
		echo timer >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/trigger
		echo 650 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wlan/delay_on
		echo 450 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/delay_on
	else
		echo none >/sys/devices/platform/leds/leds/tl-wr840n-v6:orange\:wan/trigger
		echo 0 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/brightness
	fi
	
	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		echo timer >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:lan/trigger
	else
		echo none >/sys/devices/platform/leds/leds/tl-wr840n-v6:orange\:wan/trigger
		echo none >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wlan/trigger
		echo 1 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:lan/brightness
		echo 1 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wlan/brightness
	fi
}

wr841v14() { #checking internet

	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		echo timer >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:wan/trigger
		echo none >/sys/devices/platform/leds/leds/tl-wr841n-v14:orange:wan/trigger
	else
		echo none >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:wan/trigger
		echo timer >/sys/devices/platform/leds/leds/tl-wr841n-v14:orange:wan/trigger
	fi
	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		echo 1 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:wlan/brightness
		echo timer >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/trigger
	else
		echo 500 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/delay_on
		echo 0 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/delay_off
		#echo none >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/trigger
		#echo 1 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/brightness		
	fi	
}

wr840v13() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
		echo none > trigger
	fi
	
	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wan/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wan/
		echo none > trigger
	fi
}

checking (){
	model=$(cat /proc/cpuinfo | grep 'machine' | cut -f2 -d ":" | cut -b 10-50 | tr ' ' '_')

	if [ "$model" == "TL-WR840N_v6" ];then	
		wr840v620
	elif [ "$model" == "TL-WR841N_v14" ];then	
		wr841v14		
	fi
	#asus56u
	#Clear memory
	if [ "$(cat /proc/meminfo | grep 'MemFree:' | awk '{print $2}')" -lt 5000 ]; then
		echo "Clear Cach"
		free && sync && echo 3 > /proc/sys/vm/drop_caches && free
	fi
	source /lib/functions/network.sh ; if network_get_ipaddr addr "wan"; then echo "WAN: $addr" >/tmp/ipaddr; fi
	#pidhostapd=`pidof hostapd`
	#if [ -z $pidhostapd ];then echo "Wireless Off" >/tmp/wirelessstatus;else echo "Wireless On" >/tmp/wirelessstatus;fi
}


license_srv() {

echo "" > $licensekey
wget -q "${code_srv}" -O $licensekey
curl_result=$?
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $licensekey; then
		cat "$licensekey" | while read line ; do
			if [ "$(echo $line | grep $gateway_wr84x)" ] ;then
				#Update License Key
				uci set wifimedia.@wireless[0].wfm="$(cat /etc/opt/license/wifimedia)"
				uci commit wifimedia
				cat /etc/opt/license/wifimedia >/etc/opt/license/status
				license_local
			else
					echo "enable check key"
					echo "0 0 * * * /sbin/wifimedia/controller.sh license_srv" > /etc/crontabs/wificode
					#/etc/init.d/cron restart
					disable_3_port
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
if [ "$(uci -q get wifimedia.@wireless[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
	echo "Activated" >/etc/opt/license/status
	#touch $status
	echo "" >/etc/crontabs/wificode
	/etc/init.d/cron restart	
	rm $lcs
else
	echo "Wrong License Code" >/etc/opt/license/status
fi
if [ "$uptime" -gt 15 ]; then #>15days
	if [ "$(uci -q get wifimedia.@wireless[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
		uci set wireless.radio0.disabled="0"
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
		uci commit wireless
		wifi down
	fi
fi
}

disable_3_port(){
	for i in 2 3 4; do
		swconfig dev switch0 port $i set disable 1
	done
	swconfig dev switch0 set apply
}

action_port_gateway(){
echo "" > $find_mac_gateway
wget -q "${blacklist}" -O $find_mac_gateway
curl_result=$?
if [ "${curl_result}" -eq 0 ]; then
	cat "$find_mac_gateway" | while read line ; do
		if [ "$(echo $line | grep $gateway_wr84x)" ] ;then
			for i in 1 2 3 4; do
				swconfig dev switch0 port $i set disable 1
			done
			swconfig dev switch0 set apply
		fi
	done	
fi
}

monitor_port(){
rm /tmp/monitor_port #Clear data
swconfig dev switch0 show |  grep 'link'| awk '{print $2, $3}' | while read line;do
	echo "$line," >>/tmp/monitor_port
done
ports_data==$(cat /tmp/monitor_port | xargs| sed 's/,/;/g')
echo $ports_data
#wget --post-data="gateway_mac=${global_device}&ports_data=${ports_data}" $link_post -O /dev/null
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

"$@"
