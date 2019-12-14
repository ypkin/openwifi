#!/bin/sh
# Copyright © 2013-2017 WiFiMedia.
# All rights reserved.

temp_dir="/tmp/checkin"
status_file="$temp_dir/request.txt"
response_file="$temp_dir/response.txt"
temp_file="$temp_dir/tmp"
action_data="/etc/config/action_data"

if [ ! -d "$temp_dir" ]; then
	mkdir $temp_dir
	echo "" >/tmp/checkin/request.txt
	echo "" >/tmp/checkin/response.txt

fi

#mac_device
#mac_device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
mac_device=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/:/-/g' | tr a-z A-Z)
#IP_WAN_ROUTE
ip_dhcp_client=$(ifconfig br-wan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#IP_LAN Router
ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#IP_WAN_GATEWAY
ip_gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')
#hotname
hostname=$(uci -q get system.@system[0].hostname)
wifi=$(pidof hostapd)

if [ "$wifi" != "" ];then
	wifi_status="Online"
else
	wifi_status="Offline"
fi

echo "Wifimedia checking"
echo "----------------------------------------------------------------"

echo "Calculating memory and load averages"
#memfree=$(free | grep 'Mem:' | awk '{print $4}')
#memtotal=$(free | grep 'Mem:' | awk '{print $2}')
#uptime
uptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
#load
load=$(uptime | awk '{ print $8 $9 $10 }')
echo "Getting the model information"
model_device=$(cat /proc/cpuinfo | grep 'machine' | cut -f2 -d ":" | cut -b 10-50 | tr ' ' '_')

# Saving Request Data
request_data="mac_device=${mac_device}&gateway=${ip_gateway}&ip_internal=${ip_dhcp_client}&ip_lan=${ip_lan}&model_device=${model_device}&load=${load}&uptime=${uptime}&hostname=${hostname}&wifi_status=${wifi_status}"
dashboard_protocol="http"
dashboard_server=$(uci -q get wifimedia.@sync[0].domain)
dashboard_url="checkin"
url_r="${dashboard_protocol}://${dashboard_server}/${dashboard_url}?${request_data}"

url="http://firmware.wifimedia.com.vn/test"

echo "----------------------------------------------------------------"
echo "Sending data:"

echo $url_r
wget -q "${url_r}" -O $response_file
#curl "${url}" > $response_file
curl_result=$?

if [ "$curl_result" -eq "0" ]; then
	echo "Checked in to the dashboard successfully,"

	if [ "$(cat "$response_file" | grep 'Token' | awk '{print $2}')" != "$(uci -q get wifimedia.@advance[0].token)"  ] ;then
	#if grep -q "." $response_file; then
		echo "we have new settings to apply!"
	else
		echo "we will maintain the existing settings."
		exit
	fi
else
	echo "WARNING: Could not checkin to the dashboard."
	exit
fi

echo "----------------------------------------------------------------"
echo "Applying settings"

# define the hosts file
echo "127.0.0.1 localhost" > /etc/hosts
echo "0" > /tmp/reboot_flag
echo "0" > /tmp/lanifbr_flag
echo "0" > /tmp/schedule_task_flag

cat $response_file | sed 's/=/ /g'| while read line ; do

	one=$(echo $line | awk '{print $1}')
	two=$(echo $line | awk '{print $2}')
	three=$(echo $line | awk '{print $3}')
	
	echo "Name:$one Value:$two Value:$three"
	
	#Change hotname OK
	if [ "$one" = "system.hostname" ]; then
		uci set system.@system[0].hostname="$two"
	#Restart router	
	elif [ "$one" = "system.reboot" ]; then
		echo $two > /tmp/reboot_flag
	#Password OK
	elif [ "$one" = "system.admin.passwd" ]; then
		two=$(echo $two | sed 's/*/ /g')
		echo -e "$two\n$two" | passwd admin		
		
	#time update ok
	elif [ "$one" = "wifimedia.sync.time" ]; then

		sync_time="/tmp/checkin/sync_time.txt"
		echo "*/$two * * * * /sbin/wifimedia/updates.sh" >$sync_time
		crontab $sync_time -u live
		
	#Network wan
	elif [ "$one" = "network.wan.ipaddr" ]; then
		uci set network.wan.ipaddr="$two"
	elif [ "$one" = "network.wan.netmask" ]; then
		uci set network.wan.netmask="$two"
		
	elif [ "$one" = "network.wan.proto" ]; then
		uci set network.wan.proto="$two"
	elif [ "$one" = "network.wan.type" ]; then
		uci set network.wan.type="$two"
		
	#Network LAN
	elif [ "$one" = "network.lan.ipaddr" ]; then
		uci set network.lan.ipaddr="$two"
	elif [ "$one" = "network.lan.netmask" ]; then
		uci set network.lan.netmask="$two"
		
	elif [ "$one" = "network.lan.proto" ]; then
		uci set network.lan.proto="$two"
	elif [ "$one" = "network.lan.type" ]; then
		uci set network.lan.type="$two"

	#DHCP
	elif [ "$one" = "dhcp.lan.interface" ]; then
		uci set dhcp.lan.interface="$two"	
	elif [ "$one" = "dhcp.lan.start" ]; then
		uci set dhcp.lan.start="$two"	
	elif [ "$one" = "dhcp.lan.limit" ]; then
		uci set dhcp.lan.limit="$two"					
	elif [ "$one" = "dhcp.lan.leasetime" ]; then
		uci set dhcp.lan.leasetime="$two"		
		
	#Schedule task all
	elif [ "$one" = "scheduled" ]; then
		if [ "$two" == "enable" ];then
			echo -e "0 5 * * 0,1,2,3,4,5,6 sleep 70 && touch /etc/banner && reboot" >/tmp/autoreboot
			crontab /tmp/autoreboot -u wifimedia
			/etc/init.d/cron start
			#ntpd -q -p 0.asia.pool.ntp.org				
			uci set scheduled.days.Mon=1
			uci set scheduled.days.Tue=1
			uci set scheduled.days.Wed=1
			uci set scheduled.days.Thu=1
			uci set scheduled.days.Fri=1
			uci set scheduled.days.Sat=1
			uci set scheduled.days.Sun=1
		else
			echo -e "" >/tmp/autoreboot
			crontab /tmp/autoreboot -u wifimedia
			/etc/init.d/cron start
			#ntpd -q -p 0.asia.pool.ntp.org				
			uci set scheduled.days.Mon=0
			uci set scheduled.days.Tue=0
			uci set scheduled.days.Wed=0
			uci set scheduled.days.Thu=0
			uci set scheduled.days.Fri=0
			uci set scheduled.days.Sat=0
			uci set scheduled.days.Sun=0			
		fi
	elif [ "$one" = "scheduled.time.hour" ]; then
		uci set scheduled.time.hour="$two"
		
	elif [ "$one" = "scheduled.time.minute" ]; then
		uci set scheduled.time.minute="$two"
		
	#Wireless
	#ESSID # (formerly Public ESSID)
	elif [ "$one" = "wireless.radio.enable" ]; then
		if [ "$two" == "enable" ]; then
			uci set wireless.radio0.disabled="0"
		else
			uci set wireless.radio0.disabled="1"
		fi
		
	elif [ "$one" = "wireless.essid.hide" ]; then
		uci set wireless.@wifi-iface[0].hidden="$two"
		
	elif [ "$one" = "wireless.essid.ssid" ]; then
		two=$(echo $two | sed 's/*/ /g')
		uci set wireless.@wifi-iface[0].ssid="$two"
		
	elif [ "$one" = "wireless.essid.key" ]; then
		if [ "$two" = "" ]; then
			uci set wireless.@wifi-iface[0].encryption="none"
			uci set wireless.@wifi-iface[0].key=""
		else
			uci set wireless.@wifi-iface[0].encryption="psk2"
			uci set wireless.@wifi-iface[0].key="$two"
		fi
		
	elif [ "$one" = "wireless.essid.isolate" ]; then
		uci set wireless.@wifi-iface[0].isolate="$two"
		
	#Network SSID
	elif [ "$one" = "wireless.essid.network" ]; then
		uci set wireless.@wifi-iface[0].network="$two"
		
	#AP mode
	elif [ "$one" = "wireless.essid.mode" ]; then	
		uci set wireless.@wifi-iface[0].mode="$two"

	#AP Channel
	elif [ "$one" = "wireless.essid.channel" ]; then	
		uci set wireless.@wifi-iface[0].channel="$two"
	#AP country
	elif [ "$one" = "wireless.essid.country" ]; then	
		uci set wireless.@wifi-iface[0].country="$two"	

	#AP Connect Limit
	elif [ "$one" = "wireless.essid.maxassoc" ]; then	
		uci set wireless.@wifi-iface[0].maxassoc="$two"
		
	#NASID
	elif [ "$one" = "wireless.essid.nasid" ];then
		if [ -z "$two" ];then
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
		else
			uci set wireless.@wifi-iface[0].nasid="$two"
		fi	
		uci commit wireless
	#AP 802.11i Preauth RSN
	#elif [ "$one" = "wireless.essid.rsn_preauth" ]; then	
	#	uci set wireless.@wifi-iface[0].rsn_preauth="$two"
	
	#AP 802.11r
	elif [ "$one" = "wireless.essid.fastroaming" ]; then
	
		nasid=`uci get wireless.@wifi-iface[0].nasid`
		
		if [ "$two" == "ieee80211r"  ];then
			uci set wireless.@wifi-iface[0].ieee80211r="1"
			uci set wireless.@wifi-iface[0].ft_psk_generate_local="1"
			uci delete wireless.@wifi-iface[0].rsn_preauth
			uci set wifimedia.@advance[0].ft="ieee80211r"
			echo "Fast BSS Transition Roaming" >/etc/FT
		
			if [ "$three" != "" ];then
				#Ghi du lieu APID ra file
				echo "$three" | sed 's/,/ /g' | sed 's/-/:/g' | xargs -n1 echo $nasid > /tmp/apid_list
			fi
			
			#Delete List r0kh r1kh
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
			
			#add List r0kh r1kh
			cat "/tmp/apid_list" | while read  line;do #add list R0KH va R1KH
				uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
				uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $2}'),000102030405060708090a0b0c0d0e0f"
			done

		else #Fast Roaming Preauth RSN C
			uci delete wireless.@wifi-iface[0].ieee80211r
			uci delete wireless.@wifi-iface[0].ft_psk_generate_local
			uci set wireless.@wifi-iface[0].rsn_preauth="1"
			uci set wifimedia.@advance[0].ft="rsn_preauth"
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
			uci del wireless.@wifi-iface[0].nasid
			echo "Fast-Secure Roaming" >/etc/FT
		fi	

	##upgrade
	elif [ "$one" = "ap.upgade" ]; then
		/sbin/wifimedia/controller_srv.sh upgrade_srv
	elif [ "$one" = "ap.reset" ]; then
		/sbin/wifimedia/controller_srv.sh restore_srv
	fi
done
uci set wifimedia.@advance[0].token="$(cat "$response_file" | grep 'Token' | awk '{print $2}')"
# Save all of that
uci commit

# Restart all of the services
/bin/ubus call network reload >/dev/null 2>/dev/null
/etc/init.d/system reload

if [ $(cat /tmp/lanifbr_flag) -eq 2 ]; then
	echo "moving interface: $(uci get network.lan.ifname) to the WAN"
	brctl delif br-lan $(uci -q get network.lan.ifname) && brctl addif br-wan $(uci -q get network.lan.ifname)	
fi

if [ "$(brctl show | grep br-wan | awk '{print $3}')" = "no" ]; then
	echo "stp is is disabled on the WAN, enable stp"
	# Enable stp on the wan bridge
	sleep 1 && brctl stp br-wan on
fi

#Reboot
if [ $(cat /tmp/reboot_flag) -eq 1 ]; then
	echo "restarting the node"
	reboot
fi

echo "----------------------------------------------------------------"
echo "Successfully applied new settings"
echo "update: Successfully applied new settings"
