#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

. /sbin/wifimedia/ads_filter.sh
#if [ $adsrandom == "1" ];then
##write to user.filter
#	if [ $ads_random == "6" ];then
#		img
#	elif [ $ads_random == "7" ];then
#		fbpage
#	elif [ $ads_random == "8" ];then
#		fbvideo
#	elif [ $ads_random == "9" ];then
#		fbls
#	elif [ $ads_random == "5" ];then
#		chatbot	
#	elif [ $ads_random == "3" ];then
#		youtube			
#	fi
if  [ $adsimgrandom == "1" ];then	

	if [ $ads_img_random == "1" ];then
		img1
	elif [ $ads_img_random == "2" ];then
		img2
	elif [ $ads_img_random == "3" ];then
		img3
	elif [ $ads_img_random == "4" ];then
		img4
	elif [ $ads_img_random == "5" ];then
		img5		
	fi
fi
