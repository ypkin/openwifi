#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

. /sbin/wifimedia/ads_filter.sh
#. /usr/bin/license.sh
#echo -e "*/10 * * * * /usr/bin/sync_ads.sh" >/tmp/ads_update
#echo -e "* * * * * ifup wan" >/tmp/ads_update
#crontab /tmp/ads_update -u adnetwork
#config user.action && user.filter

if [ -z $dns_acl ];then
	echo '{-filter{user-ads}}' >$action_acl
else
	echo '{+filter{user-ads}}' >$action_acl
fi

echo ${dns:-/} | sed 's/,/ /g' | xargs -n1 -r >>$action #write domain
echo ${dns_acl:-/} | sed 's/,/ /g' | xargs -n1 -r >>$action_acl #write domain


#if [ $status == "Facebook_Page" ];then
#	fbpage
#elif [ $status == "Facebook_Videos" ];then
#	fbvideo
#elif [ $status == "Facebook_Like_Share" ];then
#	fbls
#elif [ $status == "Chatbot" ];then
#	chatbot
#elif [ $status == "Youtube" ];then
#	youtube
#elif [ $status == "Image" ];then
#	img	
	
	
if [ $status == "Image1" ];then
	img1
elif [ $status == "Image2" ];then
	img2
elif [ $status == "Image3" ];then
	img3
elif [ $status == "Image4" ];then	
	img4
elif [ $status == "Image5" ];then
	img5
fi
