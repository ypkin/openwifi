#!/bin/sh

# Lấy thông tin từ nodogsplash
ndsctl status > /tmp/ndsctl_status.txt


# Update lại trạng thái đèn led
if [ ${?} -eq 0 ]; then
    #cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
    #echo 1 > brightness
	echo "Nodogsplash running"
else
    #cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
    #echo 0 > brightness
	echo "Nodogsplash crash"
    # Tự động bật lại nodogsplash nếu crash
	while true; do
		ping -c1 -W1 8.8.8.8
		if [ ${?} -eq 0 ]; then
			break
		else
			sleep 1
		fi
	done

    sh /sbin/wifimedia/preauthenticated_rules.sh
fi


# Gửi số liệu lên server
export LANG=C
urlencode() {
    arg="$1"
    i="0"
    while [ "$i" -lt ${#arg} ]; do
        c=${arg:$i:1}
        if echo "$c" | grep -q '[a-zA-Z/:_\.\-]'; then
            echo -n "$c"
        else
            echo -n "%"
            printf "%X" "'$c'"
        fi
        i=$((i+1))
    done
}

#MAC=$(ifconfig | grep br-lan | grep HWaddr | tr -s ' ' | cut -d' ' -f5)
#MAC=$(cat /sys/class/ieee80211/phy0/macaddress | tr a-z A-Z) #For TPLINK
MAC=$(ifconfig eth0 | grep 'HWaddr' | awk '{ print $5 }')
SSID=$(uci show wireless.@wifi-iface[0].ssid | cut -d= -f2 | tr -d "'")

UPTIME=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
NUM_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Client authentications since start' | cut -d':' -f2 | xargs)
RAM_FREE=$(grep -i 'MemFree:'  /proc/meminfo | cut -d':' -f2 | xargs)
#TOTAL_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Current clients' | cut -d':' -f2 | xargs)
TOTAL_CLIENTS=$(ndsctl status | grep clients | awk '{print $3}')
SSH_PORT=$(ps | grep ssh | grep '127.0.0.1:1422' | tr -s ' ' | cut -d':' -f1 | cut -d'R' -f2 | tr -d ' ')

#Value Jsion
wget -q --timeout=3 \
     "http://portal.nextify.vn/heartbeat?mac=${MAC}&uptime=${UPTIME}&num_clients=${NUM_CLIENTS}&total_clients=${TOTAL_CLIENTS}" \
     -O /tmp/config_setting
if [ $? -eq 0 ];then
	echo "Checked in to file config_setting"
	if grep -q "." /tmp/config_setting;then
		echo "we have new setting to apply!"
	else
		echo "we will maintain the existing setting."
		exit
	fi
else
	echo "WARNING: Could not download file"
fi	
###Check MD5File
network_1=$(uci -q get wireless.default_radio0.network)
network_2=$(uci -q get wireless.default_radio1.network)
md5ndsconfig=`uci -q get wifimedia.@nodogsplash[0].md5sum`
checkmd5file=`md5sum /tmp/config_setting | awk '{print $1}'`

setting_config() {
	
	while read line;do
	
		if [ "$(echo $line | grep SSID:)" ];then
			#if [ "$network_1"  == "nextify" ];then
				if [ "$(echo $line | awk '{print $2}')" != "" ];then
					uci set wireless.default_radio0.ssid="$(echo $line | awk '{print $2}')"
				fi
			#fi 
			
			#if [ "$network_2"  == "nextify" ];then
				if [ "$(echo $line | awk '{print $2}')" != "" ];then
					uci set wireless.default_radio1.ssid="$(echo $line | awk '{print $2}')"
				fi
			#fi 				
			
		elif [ "$(echo $line | grep 'PASSWORD:')" ];then 
			#if [ "$network_1"  == "nextify" ];then
			#echo $line | awk '{print $2}'
				if [ "$(echo $line | awk '{print $2}')" == "" ];then
					uci delete wireless.default_radio0.encryption &> /dev/null
					uci delete wireless.default_radio0.key &> /dev/null
					uci delete wireless.default_radio0.rsn_preauth &> /dev/null
				else	
					uci set wireless.default_radio0.encryption="psk2"
					uci set wireless.default_radio0.key="$(echo $line | awk '{print $2}')"
					uci set wireless.default_radio0.rsn_preauth=1
					
				fi
			#fi		
			#if [ "$network_2"  == "nextify" ];then
			#echo $line | awk '{print $2}'
				if [ "$(echo $line | awk '{print $2}')" == "" ];then
					uci delete wireless.default_radio1.encryption &> /dev/null
					uci delete wireless.default_radio1.key &> /dev/null
					uci delete wireless.default_radio1.rsn_preauth &> /dev/null
				else	
					uci set wireless.default_radio1.encryption="psk2"
					uci set wireless.default_radio1.key="$(echo $line | awk '{print $2}')"
					uci set wireless.default_radio1.rsn_preauth=1
					
				fi
			#fi	
		elif [ "$(echo $line | grep SESSIONTIMEOUT:)" ];then
			uci set nodogsplash.@nodogsplash[0].sessiontimeout="$(echo $line | awk '{print $2}')";
			uci set wifimedia.@nodogsplash[0].sessiontimeout="$(echo $line | awk '{print $2}')";
		elif [ "$(echo $line | grep SERVICE:)" ];then
			if [ "$(echo $line | awk '{print $2}')" == "enable" ];then
				uci set nodogsplash.@nodogsplash[0].enabled='1'
				/etc/init.d/nodogsplash enable
			else	
				uci set nodogsplash.@nodogsplash[0].enabled='0'
				/etc/init.d/nodogsplash disable
			fi	
		fi
	done < /tmp/config_setting

uci commit wireless && wifi
uci commit wifimedia
uci commit nodogsplash
/etc/init.d/nodogsplash stop
/etc/init.d/nodogsplash start
}

if [ "$md5ndsconfig" != "$checkmd5file" ];then
	echo "new config .........."
	
	uci -q set wifimedia.@nodogsplash[0].md5sum=$checkmd5file
	uci commit wifimedia
	setting_config
else
	echo "maintain the existing settings "
fi
