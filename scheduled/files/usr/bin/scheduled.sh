#!/bin/sh
#Copyright ©  dungtd8x@gmail.com

sleep 5
_mon=$(uci -q get scheduled.days.Mon)
_tue=$(uci -q get scheduled.days.Tue)
_wed=$(uci -q get scheduled.days.Wed)
_thu=$(uci -q get scheduled.days.Thu)
_fri=$(uci -q get scheduled.days.Fri)
_sat=$(uci -q get scheduled.days.Sat)
_sun=$(uci -q get scheduled.days.Sun)
_minute=$(uci -q get scheduled.time.minute)
_hour=$(uci -q get scheduled.time.hour)

if [ $_sun -eq 1 ];then
	a0="0,"
fi
if [ $_mon -eq 1 ];then
	a1="1,"
fi
if [ $_tue -eq 1 ];then
	a2="2,"
fi
if [ $_wed -eq 1 ];then
	a3="3,"
fi
if [ $_thu -eq 1 ];then
	a4="4,"
fi
if [ $_fri -eq 1 ];then
	a5="5,"
fi
if [ $_sat -eq 1 ];then	
	a6="6"
fi
echo -e "$_minute $_hour * * $a0$a1$a2$a3$a4$a5$a6 sleep 70 && touch /etc/banner && reboot" >/tmp/autoreboot
crontab /tmp/autoreboot -u wifimedia
/etc/init.d/cron start
ntpd -q -p 0.asia.pool.ntp.org
ntpd -q -p 1.asia.pool.ntp.org
ntpd -q -p 2.asia.pool.ntp.org
ntpd -q -p 3.asia.pool.ntp.org

if [ $_sun -eq 0 ] && [ $_mon -eq 0 ] && [ $_tue -eq 0 ] && [ $_wed -eq 0 ] && [ $_thu -eq 0 ] && [ $_fri -eq 0 ] && [ $_sat -eq 0 ];then
	echo -e "" >/tmp/autoreboot
	crontab /tmp/autoreboot -u wifimedia
	/etc/init.d/cron start
fi
