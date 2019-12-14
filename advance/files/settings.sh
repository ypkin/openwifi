#!/bin/sh
# Copyright © 2016 Wifimedia
# All rights reserved

# IP Hexor
hex_ip() {
	if [ -z "${mac_wlan}" ]; then
		let tmp1=0x$(echo $mac_lan | cut -c$1)
	else
		let tmp1=0x$(echo $mac_wlan | cut -c$1)
	fi
	echo $tmp1
}

# Radio Detection
radio_client="radio0"
radio_mesh="radio0"

channel_client=$(uci get wireless.${radio_client}.channel)
channel_mesh=$(uci get wireless.${radio_mesh}.channel)

# Define some networking-related variables

if_mesh=${wlan0}
#if_mesh=$(ifconfig | grep 'wlan0' | sort -r | awk '{ print $1 }' | head -1) for wlan0-1

mac_lan=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }')
mac_wan=$(ifconfig br-wan | grep 'HWaddr' | awk '{ print $5 }')
mac_wlan=$(cat /sys/class/ieee80211/phy0/macaddress)

ip_lan="10.$(hex_ip 13-14).$(hex_ip 16-17).1"
ip_lan_block="10.$(hex_ip 13-14).$(hex_ip 16-17).0"
ip_dhcp=$(ifconfig br-wan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
ip_lan_gw=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
ip_gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')

ssid="wifimedia_$(hex_ip 16-17)"

if [ "$(cat /sys/class/net/$(uci get network.wan.ifname)/carrier)" -eq "1" ]; then
	role="G"
else
	role="R"
fi

#mesh_version=$(opkg list_installed | grep 'ath9k - ' | awk '{ print $3 }' |cut -d + -f 2)	#install ath9k for mesh

