#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')
licensekey=/tmp/upgrade/licensekey
gwkey=/tmp/upgrade/licensekey
code_srv="http://firmware.wifimedia.com.vn/hardware_active"
codegw="http://firmware.wifimedia.com.vn/gwactive"
blacklist="http://firmware.wifimedia.com.vn/blacklist"

_device=`ifconfig eth0 | grep 'HWaddr' | awk '{ print $5 }' | sed 's/:/-/g' | tr a-z A-Z`
#wr940_apid=$(echo $cf_device | sed 's/:/-/g')
global_device=`ifconfig eth0 | grep 'HWaddr' | awk '{ print $5 }'| tr a-z A-Z` #Detect Client Connect Nextify
#--------------RSSI------------------------------
rssi_on=$(uci -q get wifimedia.@advance[0].enable)
#---------------controller online----------------
hardware=/tmp/upgrade/hardware
url_srv="http://firmware.wifimedia.com.vn/hardware"
version=/tmp/upgrade/version
device_fw=$(cat /sys/class/ieee80211/phy0/macaddress |sed 's/:/-/g' | tr a-z A-Z)
# Defines the URL to check the firmware at
url_fw="http://firmware.wifimedia.com.vn/tplink/$board_name.bin"
url_v="http://firmware.wifimedia.com.vn/tplink/version"
link_post=`uci -q get wifimedia.@server[0].links`
cpn_url=`uci -q get wifimedia.@nodogsplash[0].server`
#echo "Waiting a bit..."
#sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

