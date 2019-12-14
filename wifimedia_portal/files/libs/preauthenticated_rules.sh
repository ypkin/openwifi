#!/bin/sh

# Wait for network up & running
#while true; do
#    ping -c1 -W1 8.8.8.8
#    if [ ${?} -eq 0 ]; then
#        break
#    else
#        sleep 1
#    fi
#done

#Value
NODOGSPLASH_CONFIG=/tmp/etc/nodogsplash.conf
PREAUTHENTICATED_ADDRS=/tmp/preauthenticated_addrs
PREAUTHENTICATED_ADDR_FB=/tmp/preauthenticated_addr_fb
PREAUTHENTICATED_RULES=/tmp/preauthenticated_rules
#NET_ID="nextify"
NET_ID="lan"
#FW_ZONE="nextify"
#IFNAME="nextify0.1" #VLAN1
walledgadent=`uci get wifimedia.@nodogsplash[0].preauthenticated_users | sed 's/,/ /g'`
domain=`uci -q get wifimedia.@nodogsplash[0].domain`
domain_default=${domain:-portal.nextify.vn/splash}
#redirecturl=`uci -q get wifimedia.@nodogsplash[0].redirecturl`
#redirecturl_default=${redirecturl:-https://google.com.vn}
preauthenticated_users=`uci -q get wifimedia.@nodogsplash[0].preauthenticated_users` #Walled Gardent
maxclients=`uci -q get wifimedia.@nodogsplash[0].maxclients`
maxclients_default=${maxclients:-250}
preauthidletimeout=`uci -q get wifimedia.@nodogsplash[0].preauthidletimeout`
preauthidletimeout_default=${preauthidletimeout:-30}
authidletimeout=`uci -q get wifimedia.@nodogsplash[0].authidletimeout`
authidletimeout_default=${authidletimeout:-120}
sessiontimeout=`uci -q get wifimedia.@nodogsplash[0].sessiontimeout`
sessiontimeout_default=${sessiontimeout:-120}
std=`expr $sessiontimeout_default \* 60`
checkinterval=`uci -q get wifimedia.@nodogsplash[0].checkinterval`
checkinterval_default=${checkinterval:-10}
ctv=`expr $checkinterval_default \* 60`
https=`uci -q get wifimedia.@nodogsplash[0].https`
facebook=`uci -q get wifimedia.@nodogsplash[0].facebook`
MAC_E0=$(ifconfig eth0 | grep 'HWaddr' | awk '{ print $5 }')
nds_status=`uci get nodogsplash.@nodogsplash[0].enabled`
source /lib/functions/network.sh
if [ "$nds_status" == "0" ];then
	/etc/init.d/nodogsplash stop
	/etc/init.d/firewall restart
	exit;
else	

	#uci set nodogsplash.@nodogsplash[0].enabled='1'
	#uci set nodogsplash.@nodogsplash[0].gatewayinterface="br-${NET_ID}";
	#uci set nodogsplash.@nodogsplash[0].redirecturl="$redirecturl_default";
	uci set nodogsplash.@nodogsplash[0].maxclients="$maxclients_default";
	uci set nodogsplash.@nodogsplash[0].preauthidletimeout="$preauthidletimeout_default";
	uci set nodogsplash.@nodogsplash[0].authidletimeout="$authidletimeout_default";
	#uci set nodogsplash.@nodogsplash[0].sessiontimeout="$std";
	uci set nodogsplash.@nodogsplash[0].sessiontimeout="$sessiontimeout_default";
	uci set nodogsplash.@nodogsplash[0].checkinterval="$ctv";
	# Whitelist IP
	for i in portal.nextify.vn static.nextify.vn nextify.vn crm.nextify.vn $walledgadent; do
		nslookup ${i} 8.8.8.8 2> /dev/null | \
			grep 'Address ' | \
			grep -v '127\.0\.0\.1' | \
			grep -v '8\.8\.8\.8' | \
			grep -v '0\.0\.0\.0' | \
			awk '{print $3}' | \
			grep -v ':' >> ${PREAUTHENTICATED_ADDRS}
	done

	###Facebook
	for i in facebook.com fbcdn-profile-a.akamaihd.net; do
		nslookup ${i} 8.8.8.8 2> /dev/null | \
			grep 'Address ' | \
			grep -v '127\.0\.0\.1' | \
			grep -v '8\.8\.8\.8' | \
			grep -v '0\.0\.0\.0' | \
			awk '{print $3}' | \
			grep -v ':' >> ${PREAUTHENTICATED_ADDR_FB}
	done

	###Read line file 
	uci del nodogsplash.@nodogsplash[0].users_to_router
	uci del nodogsplash.@nodogsplash[0].authenticated_users
	uci del nodogsplash.@nodogsplash[0].preauthenticated_users
	uci add_list nodogsplash.@nodogsplash[0].authenticated_users="allow all"
	uci commit
	if [ $https == "1" ];then

		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to 172.16.99.1"
		if network_get_ipaddr addr "wan"; then
			#echo "IP is $addr"
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $addr"
		fi			
		while read line; do
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $(echo $line)"
		done <$PREAUTHENTICATED_ADDRS

		while read fb; do
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80 to $(echo $fb)"
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443 to $(echo $fb)"
		done <$PREAUTHENTICATED_ADDR_FB
		
		#while read fb; do
		#	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443 to $(echo $fb)"
		#done <$PREAUTHENTICATED_ADDR_FB

		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 22"
		#uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 53"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow udp port 53"		
	else
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to 172.16.99.1"	
		if network_get_ipaddr addr "wan"; then
			#echo "IP is $addr"
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $addr"
		fi		
		while read line; do
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $(echo $line)"
		done <$PREAUTHENTICATED_ADDRS
		if [ "$facebook" == "1" ];then
		while read fb; do
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80 to $(echo $fb)"
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443 to $(echo $fb)"
		done <$PREAUTHENTICATED_ADDR_FB
		fi
		#while read fb; do
		#	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443 to $(echo $fb)"
		#done <$PREAUTHENTICATED_ADDR_FB

		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 22"
		#uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80"
		#uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 53"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow udp port 53"	
	fi
	uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 22"
	uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 53"
	uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow udp port 53"
	uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow udp port 67"
	uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 80"
	uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 443"	
	uci commit nodogsplash
	rm -f $PREAUTHENTICATED_ADDRS $PREAUTHENTICATED_ADDR_FB
	#write file splash
	echo '<!doctype html>
	<html lang="en">
	  <head>
		  <meta charset="utf-8">
		  <title>$gatewayname</title>
	  </head>
	  <body>
		  <form id="info" method="POST" action="//'$domain_default'">
			  <input type="hidden" name="gateway_name" value="$gatewayname">
			  <input type="hidden" name="gateway_mac" value="'$MAC_E0'">
			  <input type="hidden" name="client_mac" value="$clientmac">
			  <input type="hidden" name="num_clients" value="$nclients">
			  <input type="hidden" name="uptime" value="$uptime">
			  <input type="hidden" name="auth_target" value="$authtarget">
		  </form>
		  <script>
			  document.getElementById("info").submit();
		  </script>
	  </body>
	</html>' >/etc/nodogsplash/htdocs/splash.html

	#write file infoskel
	echo '<!doctype html>
	<html lang="en">
		<head>
			<meta charset="utf-8">
			<title>Whoops...</title>
			<meta http-equiv="refresh" content="0; url="//'$domain'">
			<style>
				html {
					background: #F7F7F7;
				}
			</style>
		</head>
		<body></body>
	</html>' >/etc/nodogsplash/htdocs/status.html
	#/etc/init.d/nodogsplash enable

	#grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

	# Make rules
	#cat ${PREAUTHENTICATED_ADDRS} | sort | uniq | \
	#    xargs -n1 -r echo '    FirewallRule allow to' \
	#    > ${PREAUTHENTICATED_RULES}
	#
	#mkdir -p /tmp/etc/
	#
	## Render config file
	#sed -e "/# include \/tmp\/preauthenticated_rules/ {" \
	#    -e "r ${PREAUTHENTICATED_RULES}" \
	#    -e "d" \
	#    -e "}" \
	#    /etc/nodogsplash/nodogsplash.conf \
	#    > ${NODOGSPLASH_CONFIG}
	#
	## Remove comments
	#sed -i -e 's/#.*$//' ${NODOGSPLASH_CONFIG}
	#
	## T?t nodogsplash cu n?u có
	#kill -9 $(ps | grep '[n]odogsplash' | awk '{print $1}')
	#
	## B?t nodogsplash m?i
	#nodogsplash -c ${NODOGSPLASH_CONFIG}
	##if [ ${?} -eq 0 ]; then
	#   	#cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wps/
	#	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
	#   	#echo timer > trigger
	##	echo "Nodogsplash running"
	##fi


	#Create Network

	#uci commit network
	#uci commit dhcp
	#uci commit firewall
	#/etc/init.d/network restart
	#/etc/init.d/dnsmasq restart
	#/etc/init.d/firewall restart
	#sleep 5
	#iptables -I FORWARD -o br-wan -d $(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }') -j ACCEPT

	#if [ $nds_stop -eq "0" ];then
	# /etc/init.d/firewall restart
	#fi
	relay=`uci -q get network.local`
	uci del network.local.network
	if [ $relay != "" ];then
		uci add_list network.local.network='lan'
		uci add_list network.local.network='wan'
		uci commit network
		#/etc/init.d/network restart
	fi

	wifi
	/etc/init.d/nodogsplash stop
	sleep 5
	/etc/init.d/nodogsplash start

fi
