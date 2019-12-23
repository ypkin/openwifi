#!/bin/sh

#Variable
NODOGSPLASH_CONFIG=/tmp/etc/nodogsplash.conf
PREAUTHENTICATED_ADDRS=/tmp/preauthenticated_addrs
PREAUTHENTICATED_ADDR_FB=/tmp/preauthenticated_addr_fb
PREAUTHENTICATED_RULES=/tmp/preauthenticated_rules
NET_ID=`uci -q get wifimedia.@nodogsplash[0].network`
walledgadent=`uci -q get wifimedia.@nodogsplash[0].preauthenticated_users | sed 's/,/ /g'`
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
nds_status=`uci -q get nodogsplash.@nodogsplash[0].enabled`
heartbeat_url=`uci -q get wifimedia.@nodogsplash[0].heartbeat`
ip_lan_gw=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
source /lib/functions/network.sh
config_captive_portal() {
	if [ $nds_status -eq 0 ];then
		/etc/init.d/nodogsplash stop
		/etc/init.d/firewall restart
		exit;
	else	

		#uci set nodogsplash.@nodogsplash[0].enabled='1'
		uci set nodogsplash.@nodogsplash[0].gatewayinterface="${NET_ID}";
		uci set nodogsplash.@nodogsplash[0].gatewayname="CPN";
		#uci set nodogsplash.@nodogsplash[0].redirecturl="$redirecturl_default";
		uci set nodogsplash.@nodogsplash[0].maxclients="$maxclients_default";
		uci set nodogsplash.@nodogsplash[0].preauthidletimeout="$preauthidletimeout_default";
		uci set nodogsplash.@nodogsplash[0].authidletimeout="$authidletimeout_default";
		#uci set nodogsplash.@nodogsplash[0].sessiontimeout="$std";
		uci set nodogsplash.@nodogsplash[0].sessiontimeout="$sessiontimeout_default";
		uci set nodogsplash.@nodogsplash[0].checkinterval="$ctv";
		# Whitelist IP
		for i in portal.nextify.vn static.nextify.vn nextify.vn crm.nextify.vn googletagmanager.com portal.wifioto.net wifioto.net $domain $walledgadent; do
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
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to 10.68.255.1"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $ip_lan_gw"
		if network_get_ipaddr addr "wan"; then
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $addr"
		fi			
		while read line; do
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80 to $(echo $line)"
		done <$PREAUTHENTICATED_ADDRS

		if [ "$facebook" == "1" ];then
		while read fb; do
			uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80 to $(echo $fb)"
		done <$PREAUTHENTICATED_ADDR_FB
		fi

		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 22"
		#uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 53"
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow udp port 53"	

		uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 22"
		uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 53"
		uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow udp port 53"
		uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow udp port 67"
		uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 80"
		uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow tcp port 443"	
		uci commit nodogsplash
		rm -f $PREAUTHENTICATED_ADDRS $PREAUTHENTICATED_ADDR_FB

		dhcp_extension
		wifi
		/etc/init.d/nodogsplash stop
		sleep 5
		/etc/init.d/nodogsplash start
	fi
	cpn_detect
	write_login
}

captive_portal_restart(){
	# Get status nodogsplash
	ndsctl status > /tmp/ndsctl_status.txt
	if [ ${?} -eq 0 ]; then
		echo "Nodogsplash running"
	else
		echo "Nodogsplash crash"
		# Nodogsplash crash
		while true; do
			ping -c1 -W1 8.8.8.8
			if [ ${?} -eq 0 ]; then
				break
			else
				sleep 1
			fi
		done
		 /etc/init.d/nodogsplash restart >/dev/null
	fi
}

heartbeat(){
	ndsctl status > /tmp/ndsctl_status.txt
	MAC=$(ifconfig eth0 | grep 'HWaddr' | awk '{ print $5 }')
	UPTIME=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
	NUM_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Client authentications since start' | cut -d':' -f2 | xargs)
	RAM_FREE=$(grep -i 'MemFree:'  /proc/meminfo | cut -d':' -f2 | xargs)
	TOTAL_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Current clients' | cut -d':' -f2 | xargs)
	TOTAL_CLIENTS=$(ndsctl status | grep clients | awk '{print $3}')
	#Value Jsion
	#wget -q --timeout=3 \
	#	 "http://portal.nextify.vn/heartbeat?mac=${MAC}&uptime=${UPTIME}" \
	#	 -O /dev/null
	captive_portal_restart
	wget -q --timeout=3 \
	"http://portal.nextify.vn/heartbeat?mac=${MAC}&uptime=${UPTIME}&num_clients=${NUM_CLIENTS}&total_clients=${TOTAL_CLIENTS}" \
	 -O /dev/null
}

get_captive_portal_clients() {
     #trap "error_trap get_captive_portal_clients '$*'" $GUARD_TRAPS
     local line
     local key
     local value
     local ip_address=
     local mac_address=
     local connection_timestamp=
     local activity_timestamp=
     local traffic_download=
     local traffic_upload=
	 local global_device=`ifconfig eth0 | grep 'HWaddr' | awk '{ print $5 }'`
     # erzwinge eine leere Zeile am Ende fuer die finale Ausgabe des letzten Clients
     (ndsctl clients; echo) | while read line; do
         key=$(echo "$line" | cut -f 1 -d =)
         value=$(echo "$line" | cut -f 2- -d =)
         [ "$key" = "ip" ] && ip_address="$value"
         [ "$key" = "mac" ] && mac_address="$value"
         [ "$key" = "added" ] && connection_timestamp="$value"
         [ "$key" = "active" ] && activity_timestamp="$value"
         [ "$key" = "downloaded" ] && traffic_download="$value"
         [ "$key" = "uploaded" ] && traffic_upload="$value"
         if [ -z "$key" -a -n "$ip_address" ]; then
             # leere Eingabezeile trennt Clients: Ausgabe des vorherigen Clients
             printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
                 "$ip_address" "$mac_address" "$connection_timestamp" \
                 "$activity_timestamp" "$traffic_download" "$traffic_upload"
	     data=";$mac_address"
	     echo $data >>/tmp/captive_portal_clients
             ip_address=
             mac_address=
             connection_timestamp=
             activity_timestamp=
             traffic_download=
             traffic_upload=
         fi
    done
	#clients_ndsclt=$(cat /tmp/captive_portal_clients | xargs| sed 's/;/,/g'| tr a-z A-Z)
	###2>/dev/null
	#wget --post-data="clients=${clients_ndsclt}&gateway_mac=${global_device}" http://api.nextify.vn/clients_around 2>/dev/null
    #rm /tmp/captive_portal_clients	
 }

write_login(){

	#write file splash
	echo '<!doctype html>
	<html lang="en">
	  <head>
		  <meta charset="utf-8">
		  <title>$gatewayname</title>
	  </head>
	  <body>
		  <form id="info" method="POST" action="//'$domain_default'">
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
}

dhcp_extension(){
	relay=`uci -q get network.local`
	uci del network.local.network
	if [ $relay != "" ];then
		if [ $NET_ID = "br-hotspot" ];then
			uci set network.local.ipaddr='10.68.255.1'
			uci add_list network.local.network='hotspot'
			uci set dhcp.hotspot.ignore='1'
			uci set wireless.default_radio0.network='hotspot'
			uci set wireless.default_radio1.network='hotspot'
		else
			uci set network.local.ipaddr='172.16.99.1'
			uci add_list network.local.network='lan'
			uci set dhcp.lan.ignore='1'
			uci set wireless.default_radio0.network='lan'
			uci set wireless.default_radio1.network='lan'
		fi	
		uci add_list network.local.network='wan'
	else
		NET_ID=`uci -q get wifimedia.@nodogsplash[0].network`
		if [ $NET_ID = "br-hotspot" ];then
			uci set wireless.default_radio0.network='hotspot'
			uci set wireless.default_radio1.network='hotspot'
		else
			uci set wireless.default_radio0.network='lan'
			uci set wireless.default_radio1.network='lan'
		fi	
		uci set dhcp.lan.ignore='0'
		uci set dhcp.hotspot.ignore='0'

	fi
	uci commit && wifi up
}
cpn_detect(){
	cpn_status=`uci -q get wifimedia.@nodogsplash[0].cpnurl`
	if [ $cpn_status -eq 0 ];then
		echo '* * * * * /sbin/wifimedia/captive_portal.sh heartbeat'>/etc/crontabs/nds && /etc/init.d/cron restart
	fi
}
"$@"
