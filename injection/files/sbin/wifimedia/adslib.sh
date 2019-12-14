#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

#. /sbin/wifimedia/ads_settings.sh
user_acl_filter=/etc/privoxy/useracl.filter
ads_img=/tmp/img.txt
ads_fb_page=/tmp/fbpage.txt
ads_fb_video=/tmp/fbvideo.txt
ads_fb_like=/tmp/fblike.txt
chatbot=/tmp/chatbot.txt
adjs=/www/luci-static/resources/wifimedia.js
js=/www/luci-static/resources/fb.js
action=/etc/privoxy/user.action
action_acl=/etc/privoxy/useracl.action
user_filter=/etc/privoxy/user.filter
filter=/etc/privoxy/user.filter
##IMG
link1=$(uci -q get wifimedia.@adnetwork[0].link1)
img1=$(uci -q get wifimedia.@adnetwork[0].img1)

link2=$(uci -q get wifimedia.@adnetwork[0].link2)
img2=$(uci -q get wifimedia.@adnetwork[0].img2)

link3=$(uci -q get wifimedia.@adnetwork[0].link3)
img3=$(uci -q get wifimedia.@adnetwork[0].img3)

link4=$(uci -q get wifimedia.@adnetwork[0].link4)
img4=$(uci -q get wifimedia.@adnetwork[0].img4)

link5=$(uci -q get wifimedia.@adnetwork[0].link)
img5=$(uci -q get wifimedia.@adnetwork[0].img)

##END IMG
fb_page=$(uci -q get wifimedia.@adnetwork[0].ads_fb_page)
fb_video=$(uci -q get wifimedia.@adnetwork[0].ads_fb_video)
fb_like=$(uci -q get wifimedia.@adnetwork[0].ads_fb_like)
ads_sec=$(uci -q get wifimedia.@adnetwork[0].second)
page_id=$(uci -q get wifimedia.@adnetwork[0].facebook_id)
ref=$(uci -q get wifimedia.@adnetwork[0].ref)
youtube=$(uci -q get wifimedia.@adnetwork[0].youtube)

ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')

#ads_random=`head /dev/urandom | tr -dc "56789" | head -c1`
ads_img_random=`head /dev/urandom | tr -dc "56789" | head -c1`

adsrandom=`uci -q get wifimedia.@adnetwork[0].random_status`
adsimgrandom=`uci -q get wifimedia.@adnetwork[0].random_image_status`

gateway=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
apkey=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/://g'|tr A-Z a-z)
dns=$(uci -q get wifimedia.@adnetwork[0].domain)
dns_acl=$(uci -q get wifimedia.@adnetwork[0].domain_acl)
apkey=$(uci -q get wifimedia.@adnetwork[0].gw)
status=$(uci -q get wifimedia.@adnetwork[0].status)
gw=${apkey:-$wlan}
wlan=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/://g') #get mac wlan
link=$(uci -q get wifimedia.@adnetwork[0].link)
#wlan=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }' | sed 's/://g'|tr A-Z a-z) #get mac wlan

#status_img=$(uci -q get wifimedia.@adnetwork[0].ads_img)
#status_title=$(uci -q get wifimedia.@adnetwork[0].ads_title)
#ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#uci -q get wifimedia.@adnetwork[0].domain | sed 's/,/ /g' | xargs -n1 -r >>$action #write domain
#uci -q get wifimedia.@adnetwork[0].domain_acl | sed 's/,/ /g' | xargs -n1 -r >>$action_acl #write domain


