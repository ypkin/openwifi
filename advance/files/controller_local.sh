#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh

bw24=`uci -q get wifimedia.@wireless[0].bw24g`
essid=`uci -q get wifimedia.@wireless[0].essid`
network24=`uci -q get wifimedia.@wireless[0].network`
mode24=`uci -q get wifimedia.@wireless[0].mode`
channel24=`uci -q get wifimedia.@wireless[0].channel`
maxassoc24=`uci -q get wifimedia.@wireless[0].maxassoc`
encryption24=`uci -q get wifimedia.@wireless[0].encrypt`
passwd24=`uci -q get wifimedia.@wireless[0].password`
ft24=`uci -q get wifimedia.@wireless[0].ft`
ft_psk_generate_local24=`uci -q get wifimedia.@wireless[0].ft_psk_generate_local`
nasid=`uci -q get wifimedia.@wireless[0].nasid`
txpower24=`uci -q get wifimedia.@wireless[0].txpower`
hidessid24=`uci -q get wifimedia.@wireless[0].hidessid`
isolation24=`uci -q get wifimedia.@wireless[0].isolation`
group_mac=`uci -q get wifimedia.@wireless[0].macs |sed 's/-/:/g' | sed  's/,/ /g'|xargs -n1`

bw5=`uci -q get wifimedia.@wireless[0].bw5g`
essidfive=`uci -q get wifimedia.@wireless[0].essidfive`
modefive=`uci -q get wifimedia.@wireless[0].modefive`
channelfive=`uci -q get wifimedia.@wireless[0].channelfive`
maxassocfive=`uci -q get wifimedia.@wireless[0].maxassocfive`
networkfive=`uci -q get wifimedia.@wireless[0].networkfive`
encryptfive=`uci -q get wifimedia.@wireless[0].encryptfive`
passwordfive=`uci -q get wifimedia.@wireless[0].passwordfive`
ftfive=`uci -q get wifimedia.@wireless[0].ftfive`
ft_psk_generate_localfive=`uci -q get wifimedia.@wireless[0].ft_psk_generate_localfive`
nasidfive=`uci -q get wifimedia.@wireless[0].nasidfive`
txpowerfive=`uci -q get wifimedia.@wireless[0].txpowerfive`
hidessidfive=`uci -q get wifimedia.@wireless[0].hidessidfive`
isolationfive=`uci -q get wifimedia.@wireless[0].isolationfive`
txpowerfive=`uci -q get wifimedia.@wireless[0].txpowerfive`
group_macfive=`uci -q get wifimedia.@wireless[0].macsfive |sed 's/-/:/g' | sed  's/,/ /g'|xargs -n1` 
VLAN_ID24G=`uci -q get wifimedia.@wireless[0].vlan24g`
VLAN_ID5G=`uci -q get wifimedia.@wireless[0].vlan5g`
#IFNAME="eth1" #for comfast
IFNAME="eth0" #for TPLINK
NET_ID24G="VLAN_${VLAN_ID24G}"
NET_ID5G="VLAN_${VLAN_ID5G}"
echo $group_macfive
local_config(){

if [ "$bw24" == "1" ];then
	#Network
	#VLAN_ID=`uci -q get wifimedia.@wireless[0].vlan24g`
	#IFNAME="eth1"
	#NET_ID24G="VLAN_${VLAN_ID24G}"
	#echo $NET_ID24G
	#network24=`uci -q get wifimedia.@wireless[0].network`
	if [ "$network24" == "vlanx24" ];then
		vlan24g_add
		uci set wireless.default_radio0.network="$NET_ID24G"
	else
		vlan24g_del
		uci set wireless.default_radio0.network="$network24"
	fi
	#uci commit
	#Mode
	uci set wireless.default_radio0.mode="$mode24"
	#ESSID
	if [ -z "$essid" ];then
		echo "no change SSID"
	else 
		uci set wireless.default_radio0.ssid="$essid"
	fi
	#channel
	uci set wireless.radio0.channel="$channel24"
	#Connect Limit
	uci set wireless.default_radio0.maxassoc="$maxassoc24"
	#Passwd ssid
	if [ -z "$passwd24" ];then

		uci delete wireless.default_radio0.encryption
		uci delete wireless.default_radio0.key
		uci delete wireless.default_radio0.ieee80211r
		uci delete wireless.default_radio0.rsn_preauth
		rm -f >/etc/FT
	else
		uci set wireless.default_radio0.encryption="psk2"
		uci set wireless.default_radio0.key="$passwd24"
		uci set wireless.default_radio0.rsn_preauth="1"
	fi
	#Fast Roaming
	if [ "$ft24" == "ieee80211r"  ];then
		uci set wireless.default_radio0.ieee80211r="1"
		uci set wireless.default_radio0.ft_psk_generate_local="0"
		uci set wireless.default_radio0.pmk_r1_push="1"
		uci delete wireless.default_radio0.rsn_preauth
		echo "Fast BSS Transition Roaming" >/etc/FT
		##fix PMK if pmk locally = 1
		if [ "$ft_psk_generate_local24" == "1" ];then
			uci set wireless.default_radio0.ft_psk_generate_local="1"
			#delete all r0kh r1kh
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
		elif [ "$ft_psk_generate_local24" == "0" ];then #if pmk locally = ""
			uci set wireless.default_radio0.ft_psk_generate_local="0"
			#delete all r0kh r1kh
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
														   
			#group_mac=`uci -q get wifimedia.@wireless[0].macsfive |sed 's/-/:/g' | sed  's/,/ /g'|xargs -n1` 
			echo "$group_mac" | while read mac;do #add list R0KH va R1KH
				uci add_list wireless.default_radio0.r0kh="$mac,$nasid,000102030405060708090a0b0c0d0e0f"
				uci add_list wireless.default_radio0.r1kh="$mac,$mac,000102030405060708090a0b0c0d0e0f"
			done
		fi
		#end config r0kh & r1kh
		
		if [ "$(uci -q get wifimedia.@wireless[0].macs)" == "" ];then
		#echo "test rong"
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh	
		fi
		#uci commit wireless
	elif [ "$ft24" == "rsn_preauth" ];then
		uci delete wireless.default_radio0.ieee80211r
		uci delete wireless.default_radio0.ft_psk_generate_local
		uci delete wireless.default_radio0.pmk_r1_push
		uci set wireless.default_radio0.rsn_preauth="1"
		uci del wireless.default_radio0.r0kh
		uci del wireless.default_radio0.r1kh
		echo "Fast-Secure Roaming" >/etc/FT
	else
		rm -f /etc/FT
	fi
	#NASID
	if [ -z "$nasid" ];then
		uci del wireless.default_radio0.r0kh
		uci del wireless.default_radio0.r1kh
	else
		uci set wireless.default_radio0.nasid="$nasid"
	fi	

	#TxPower
	if [ "$txpower24" == "auto"  ];then
		uci delete wireless.radio0.txpower
	elif [ "$txpower24" == "low"  ];then
		uci set wireless.radio0.txpower="15"
	elif [ "$txpower24" == "medium"  ];then
		uci set wireless.radio0.txpower="20"
	elif [ "$txpower24" == "high"  ];then
		uci set wireless.radio0.txpower="22"
	fi
	
	#Hide SSID
	uci set wireless.default_radio0.hidden="$hidessid24"
	#ISO             default_radio0
	uci set wireless.default_radio0.isolate="$isolation24"
									 
									 
	uci commit wireless
fi

########Radio 5G
#if [ "$bw5" == "1" ];then
#	#Network
#	if [ "$networkfive" == "vlanx5" ];then
#		vlan5g_add
#		uci set wireless.default_radio0.network="$NET_ID5G"
#	else
#		vlan5g_del
#		uci set wireless.default_radio0.network="$networkfive"
#	fi	
#	#Mode
#	uci set wireless.default_radio0.mode="$modefive"
#	#ESSID
#	if [ -z "$essidfive" ];then
#		echo "no change SSID"
#	else 
#		uci set wireless.default_radio0.ssid="$essidfive"
#	fi
#	#channel
#	uci set wireless.radio0.channel="$channelfive"
#	#Connect Limit
#	uci set wireless.default_radio0.maxassoc="$maxassocfive"
#	#Passwd ssid
#	if [ -z "$passwordfive" ];then
#		uci delete wireless.default_radio0.encryption
#		uci delete wireless.default_radio0.key
#		uci delete wireless.default_radio0.ieee80211r
#		uci delete wireless.default_radio0.rsn_preauth
#		rm -f >/etc/FT
#	else
#		uci set wireless.default_radio0.encryption="psk2"
#		uci set wireless.default_radio0.key="$passwordfive"
#	fi
#	#Fast Roaming
#	if [ "$ftfive" == "ieee80211rfive"  ];then
#		uci set wireless.default_radio0.ieee80211r="1"
#		uci set wireless.default_radio0.ft_psk_generate_local="0"
#		uci set wireless.default_radio0.pmk_r1_push="1"
#		uci delete wireless.default_radio0.rsn_preauth
#		echo "Fast BSS Transition Roaming" >/etc/FT
#		##fix PMK if pmk locally = 1
#		if [ "$ft_psk_generate_localfive" == "1" ];then
#			uci set wireless.default_radio0.ft_psk_generate_local="1"
#			#delete all r0kh r1kh
#			uci del wireless.default_radio0.r0kh
#			uci del wireless.default_radio0.r1kh
#		elif [ "$ft_psk_generate_localfive" == "0" ];then #if pmk locally = ""
#			uci set wireless.default_radio0.ft_psk_generate_local="0"
#			#delete all r0kh r1kh
#			uci del wireless.default_radio0.r0kh
#			uci del wireless.default_radio0.r1kh
#			#nasidfive=`uci -q get wifimedia.@wireless[0].nasidfive`
#			#group_macfive=`uci -q get wifimedia.@wireless[0].macsfive |sed 's/-/:/g' | sed  's/,/ /g'|xargs -n1` 
#			echo "$group_macfive" | while read mac;do #add list R0KH va R1KH
#				uci add_list wireless.default_radio0.r0kh="$mac,$nasidfive,000102030405060708090a0b0c0d0e0f"
#				uci add_list wireless.default_radio0.r1kh="$mac,$mac,000102030405060708090a0b0c0d0e0f"
#			done
#		fi
#		#end config r0kh & r1kh
#		
#		if [ "$(uci -q get wifimedia.@wireless[0].macsfive)" == "" ];then
#		#echo "test rong"
#			uci del wireless.default_radio0.r0kh
#			uci del wireless.default_radio0.r1kh	
#		fi
#		#uci commit wireless
#	elif [ "$ftfive" == "rsn_preauthfive" ];then
#		uci delete wireless.default_radio0.ieee80211r
#		uci delete wireless.default_radio0.ft_psk_generate_local
#		uci delete wireless.default_radio0.pmk_r1_push
#		uci set wireless.default_radio0.rsn_preauth="1"
#		uci del wireless.default_radio0.r0kh
#		uci del wireless.default_radio0.r1kh
#		echo "Fast-Secure Roaming" >/etc/FT
#	else
#		rm -f /etc/FT
#	fi
#	#NASID
#	if [ -z "$nasidfive" ];then
#		uci del wireless.default_radio0.r0kh
#		uci del wireless.default_radio0.r1kh
#	else
#		uci set wireless.default_radio0.nasid="$nasidfive"
#	fi	
#
#	#TxPower
#	if [ "$txpowerfive" == "auto"  ];then
#		uci delete wireless.radio0.txpower
#	elif [ "$txpowerfive" == "low"  ];then
#		uci set wireless.radio0.txpower="17"
#	elif [ "$txpowerfive" == "medium"  ];then
#		uci set wireless.radio0.txpower="20"
#	elif [ "$txpowerfive" == "high"  ];then
#		uci set wireless.radio0.txpower="22"
#	fi
#	
#	#Hide SSID
#	uci set wireless.default_radio0.hidden="$hidessidfive"
#	#ISO
#	uci set wireless.default_radio0.isolate="$isolationfive"
#	uci set wireless.radio0.disabled="0"
#	uci set wireless.radio1.disabled="0"
#	uci commit wireless
#fi

sleep 5 && wifi
/etc/init.d/network reload

}


vlan24g_add(){
	#VLAN_ID24G=`uci -q get wifimedia.@wireless[0].vlan24g`
	#IFNAME="eth1"
	#NET_ID24G="VLAN_${VLAN_ID24G}"
	#echo $NET_ID24G
	uci	set network.${NET_ID24G}=interface
	uci	set network.${NET_ID24G}.ifname="${IFNAME}.${VLAN_ID24G}"
	uci	set wifimedia.@wireless[0].vlanx24="${NET_ID24G}"
	#uci	set network.${NET_ID24G}.proto=static
	#uci	set network.${NET_ID24G}.type=bridge
	#uci	set network.${NET_ID24G}.ipaddr=10.200.255.1
	#uci	set network.${NET_ID24G}.netmask=255.255.255.0
	uci	commit network
}

vlan24g_del(){
	#NET_ID="VLAN_${VLAN_ID}"
	VLANX24=`uci -q get wifimedia.@wireless[0].vlanx24`
	uci	delete network.${VLANX24}
	uci	commit network
}

vlan5g_add(){
	#NET_ID5G=`uci -q get wifimedia.@wireless[0].vlan5g`
	#IFNAME="eth1"
	#NET_ID5G="VLAN_${VLAN_ID5G}"
	#echo $NET_ID5G
	uci	set network.${NET_ID5G}=interface
	uci	set network.${NET_ID5G}.ifname="${IFNAME}.${VLAN_ID5G}"
	uci	set wifimedia.@wireless[0].vlanx5="${NET_ID5G}"
	#uci	set network.${NET_ID5G}.proto=static
	#uci	set network.${NET_ID5G}.type=bridge
	#uci	set network.${NET_ID5G}.ipaddr=10.200.255.1
	#uci	set network.${NET_ID5G}.netmask=255.255.255.0
	uci	commit network
}

vlan5g_del(){
	#NET_ID="VLAN_${VLAN_ID}"
	VLANX5=`uci -q get wifimedia.@wireless[0].vlanx5`
	uci	delete network.${VLANX5}
	uci	commit network
}

rssi() {

if [ $rssi_on == "1" ];then
	level_defaults=-80
	level=$(uci -q get wifimedia.@advance[0].level)
	level=${level%dBm}
	LOWER=${level:-$level_defaults}
	#echo $LOWER	
	dl_time=$(uci -q get wifimedia.@advance[0].delays)
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
