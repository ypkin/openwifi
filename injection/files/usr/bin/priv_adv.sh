#!/bin/sh

#domain=$(uci get wifimedia.@whitelist[0].domain | xargs -n1 -r)
gateway=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
apkey=$(ifconfig br-wan | grep 'HWaddr'| awk '{ print $5}'| sed 's/://g'|tr A-Z a-z)
#action=/etc/privoxy/user.action
#filter=/etc/privoxy/user.filter
#Injection all 
#echo "{+filter{browser-adv}}
#/.*" >$action
#Not Injection
#echo "{ -filter{browser-adv}}">>$action
#echo ".google.com
#.google.com.vn
#.facebook.com">>$action
#echo "$gateway" >>$action
#echo "$domain" >>$action
#FILTER
#echo "FILTER: browser-adv Add advertise to WEB" >$filter
#echo "s/<\/head/\r\n<script src='http:\/\/test.quangcaowifi.vn\/public\/maisat\/jquery.js'><\/script>\r\n<script src='http:\/\/test.quangcaowifi.vn\/public\/maisat\/lib.js'><\/script>\r\n<script src='http:\/\/test.quangcaowifi.vn\/public\/maisat\/administrator.js'><\/script>\r\n<\/head/is" >>$filter
#echo "s/<\/head/\r\n<img src='http:\/\/topanhdep.net\/wp-content\/uploads\/2015\/12\/anh-girl-xinh-gai-dep-98-13.jpg'><\/img>\r\n<\/head/is">>$filter
