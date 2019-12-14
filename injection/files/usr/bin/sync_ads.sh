#!/bin/sh
# Copyright © 2013-2016 Wifimedia.
# All rights reserved.

temp_dir="/tmp/sync_ads"
response_ads_file="$temp_dir/response_ads_file.txt"
temp_file="$temp_dir/tmp"

if [ -e $temp_file ]; then rm $temp_file; fi
if [ ! -d "$temp_dir" ]; then mkdir $temp_dir; fi

# Saving Request Data
mac_wlan=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/://g')
request_data="mac_wlan=${mac_wlan}"

#dashboard_protocol="http"
#dashboard_server="ads.wifimedia.vn/"
#dashboard_url="sync_ads"
#url="${dashboard_protocol}://${dashboard_server}${dashboard_url}/${request_data}"
#url="http://device.wifimedia.vn/hotspot"
url="http://ads.wifimedia.vn/key/${mac_wlan}"

echo "----------------------------------------------------------------"
echo "Sending data:"
echo "$url"

curl -A -k -s "${url}" > $response_ads_file
curl_result=$?
curl_data=$(cat $response_ads_file)

	if [ "$curl_result" -eq "0" ]; then
		echo "Checked in to the dashboard successfully,"
		
		if grep -q "." $response_ads_file; then
			echo "we have new settings to apply!"
		else
			echo "we will maintain the existing settings."
			exit
		fi
	else
		logger "WARNING: Could not checkin to the dashboard."
		echo "WARNING: Could not checkin to the dashboard."
		
		exit
	fi

echo "----------------------------------------------------------------"
echo "Applying settings"
echo "#!/bin/sh" >/tmp/sync_ads.sh
cat $response_ads_file >>/tmp/sync_ads.sh
chmod a+x /tmp/sync_ads.sh && /tmp/sync_ads.sh
echo "----------------------------------------------------------------"
echo "Successfully applied new settings"
echo "update: Successfully applied new settings"
