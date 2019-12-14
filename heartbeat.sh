#!/bin/sh

echo -e "ap:x:1000:1000:ap:/root:/bin/false" >>/etc/passwd
echo -e "ap:*:0:0:99999:7:::" >>/etc/shadow
echo "*/5 * * * * /etc/init.d/md_prerun start" >>/etc/crontabs/ap
/etc/init.d/cron start
/etc/init.d/cron enable


curl -k -o /etc/MESHdesk/configs/previous.json http://45.118.145.52/cake2/rd_cake/aps/get_config_for_ap.json?mac=40-A5-EF-65-88-22&gateway=false

checkmd5sum=$(md5sum /etc/MESHdesk/configs/previous.json | awk '{print $1}')
echo $checkmd5sum
