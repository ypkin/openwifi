#!/bin/sh

#Delete Network
NET_ID="nextify"
FW_ZONE="nextify"
/etc/init.d/nodogsplash disable
uci set nodogsplash.@nodogsplash[0].enabled='0'
uci commit

#uci batch << EOF
#	del network.${NET_ID}
#	del dhcp.${NET_ID}
#	del firewall.${FW_ZONE}
#	set nodogsplash.@nodogsplash[0].enabled='0'
#EOF
#uci commit network
#uci commit dhcp
#uci commit firewall
#/etc/init.d/network restart
#/etc/init.d/dnsmasq restart
/etc/init.d/nodogsplash stop
/etc/init.d/firewall restart
#/etc/init.d/nodogsplash restart
