#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh
startup() {
echo "" > $hardware
wget -q "${url_srv}" -O $hardware
curl_result=$?
}

btn_reset() {

startup
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].button)" != "$(echo $line | awk '{print $4}')" ]; then
				if [ "$(echo $line | grep $device_fw)" ] ;then
					#Button Reset
						chmod a+x /etc/btnaction
						uci set wifimedia.@sync[0].button="$(echo $line | awk '{print $4}')"
						uci commit wifimedia
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done	
	#else
	#	echo "Could not connect to the upgrade server, exiting..."
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi

}

passwd_admin_srv() {

startup
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].passwd)" != "$(echo $line | awk '{print $1}')" ]; then
				if [ "$(echo $line | grep $device_fw)" ] ;then
					#Reset defaults passwd
					echo -e "wifimedia\nwifimedia" | passwd admin
					uci set wifimedia.@sync[0].passwd="$(echo $line | awk '{print $1}')"
					uci commit wifimedia
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done	
	#else
	#	echo "Could not connect to the upgrade server, exiting..."
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi

}

passwd_wifi() {

startup
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].passwdwifi)" != "$(echo $line | awk '{print $2}')" ]; then
				if [ "$(echo $line | grep $device_fw)" ] ;then
					#delete passwifi radio master
					uci set wireless.@wifi-iface[0].encryption="none"
					uci set wireless.@wifi-iface[0].key=""
					uci commit wireless
					uci set wifimedia.@sync[0].passwdwifi="$(echo $line | awk '{print $2}')"
					uci commit wifimedia
					wifi
					echo  "delete password wifi success"
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done
	fi
fi
}

preauth_rsn_srv() {
startup
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].rsn)" != "$(echo $line | awk '{print $6}')" ]; then
				if [ "$(echo $line | grep $device_fw)" ] ;then
					#802.11i passwifi radio master
					uci set wireless.@wifi-iface[0].ssid="PDA"
					uci set wireless.@wifi-iface[0].encryption="mixed-psk"
					uci set wireless.@wifi-iface[0].key="123456A@"
					uci set wireless.@wifi-iface[0].rsn_preauth=1
					uci set wireless.@wifi-iface[0].ieee80211r=0
					uci commit wireless
					uci set wifimedia.@sync[0].rsn="$(echo $line | awk '{print $6}')"
					uci commit wifimedia
					wifi
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
}

restore_srv() {
startup
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].ftrs)" != "$(echo $line | awk '{print $3}')" ]; then
				if [ "$(echo $line | grep $device_fw)" ] ;then
					#Reset defaults model
					sleep 1; jffs2reset -y && reboot
					#echo "reset default modem"
					uci set wifimedia.@sync[0].ftrs="$(echo $line | awk '{print $3}')"
					uci commit wifimedia
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done
	fi
fi
}

upgrade_srv() {

echo "" > $version
echo "Checking latest version number"
wget -q "${url_v}" -O $version
echo "Getting latest version hashes and filenames"
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $version; then
		cat "$version" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].version)" != "$(echo $line | awk '{print $7}')" ]; then
				# Make sure no old firmware exists
				#if [ -e "/tmp/firmware.bin" ]; then rm "/tmp/firmware.bin"; fi
				#echo "Checking for upgrade binary"
				if [ "$(echo $line | grep $device_fw)" ] ;then
					#echo "Downloading upgrade binary: $(grep $(cat /tmp/sysinfo/board_name)'-squashfs-sysupgrade' /tmp/upgrade/md5sums | awk '{ print $2 }' | sed 's/*//')"
					wget -q "${url_fw}" -O /tmp/firmware.bin
					# Stop if the firmware file does not exist
					if [ ! -e "/tmp/firmware.bin" ]; then
						echo "The upgrade binary download was not successful, exiting..."
					
					# If the hash is correct: flash the firmware
					elif [ "$(echo $line | awk '{print $3}')" = "$(sha256sum /tmp/firmware.bin | awk '{ print $1 }')" ]; then
						#remove all crontabs/*
						rm -f /etc/crontabs/*
						#remove option wireless
							uci del_list wireless.radio0.ht_capab="SHORT-GI-20"
							uci del_list wireless.radio0.ht_capab="SHORT-GI-40"
							uci del_list wireless.radio0.ht_capab="RX-STBC1"
							uci del_list wireless.radio0.ht_capab="DSSS_CCK-40"
							uci commit wireless
						logger "Installing upgrade binary..."
						if [ "$(echo $line | grep all)" ] ;then
							sysupgrade -v -n /tmp/firmware.bin
						else
							sysupgrade -c /tmp/firmware.bin
						fi	
						#sysupgrade -c -d 600 /tmp/firmware.bin
					# The hash is invalid, stopping here
					else
						echo "The upgrade binary hash did not match, exiting..."
					fi	
				#else
				#	echo "There is no upgrade binary for this device ($(cat /tmp/sysinfo/model)/$(cat /tmp/sysinfo/board_name)), exiting..."
				fi
			#else
			#	echo "Update Version: v$(echo $line | awk '{print $1}') is the latest firmware version available."
			fi
		done
	fi
fi

}

"$@"
