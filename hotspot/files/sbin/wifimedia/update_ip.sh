#!/bin/sh

# Wait for network up & running
while true; do
    ping -c1 -W1 8.8.8.8
    if [ $? -eq 0 ]; then
        break
    else
        sleep 1
    fi
done

tmp_ip_facebook=/tmp/ip_facebook
tmp_ip_google=/tmp/ip_google
tmp_ip_apple=/tmp/ip_apple
tmp_ip_microsoft=/tmp/microsoft
_ip_facebook=/etc/config/ip_facebook
_ip_google=/etc/config/ip_google
_ip_apple=/etc/config/ip_apple
_ip_microsoft=/etc/config/ip_microsoft

echo '' > $tmp_ip_facebook
echo '' > $tmp_ip_google
echo '' > $tmp_ip_apple
echo '' > $tmp_ip_microsoft
echo '' > $_ip_facebook
echo '' > $_ip_google
echo '' > $_ip_apple
echo '' > $_ip_microsoft

fb=$(uci -q get wifimedia.@hotspot[0].facebook)
gg=$(uci -q get wifimedia.@hotspot[0].google)
app=$(uci -q get wifimedia.@hotspot[0].iphone)
ms=$(uci -q get wifimedia.@hotspot[0].windowsphone)

# Get list IPs
if [ $fb -eq 1 ];then
	for domain in \
				www.facebook.com \
				connect.facebook.net \
				fbcdn-profile-a.akamaihd.net \
				fbcdn-photos-d-a.akamaihd.net \
				web.facebook.com \
				m.facebook.com
	do
		# with client subnet
		nslookup $domain 8.8.8.8 | \
			grep 'Address ' | \
			grep -v '127\.0\.0\.1' | \
			grep -v '8\.8\.8\.8' | \
			grep -v '0\.0\.0\.0' | \
			awk '{print $3}' | \
			grep -v ':' >> $tmp_ip_facebook
	done
	cat $tmp_ip_facebook | \
    sort | uniq | \
    xargs -r \
    > $_ip_facebook	
fi
	
if [ $gg -eq 1 ];then

	for domain in \
				www.google-analytics.com \
				google.com \
				accounts.google.com \
				googleapis.com \
				gmail.com \
				picasa.google.com \
				gstatic.com \
				labs.google.com \
				m.youtube.com\
				youtube.com\
				www.youtube.com\
				youtu.be\
				googlevideo.com\
				com.google.android.youtube
	do
		# with client subnet
		nslookup $domain 8.8.8.8 | \
			grep 'Address ' | \
			grep -v '127\.0\.0\.1' | \
			grep -v '8\.8\.8\.8' | \
			grep -v '0\.0\.0\.0' | \
			awk '{print $3}' | \
			grep -v ':' >> $tmp_ip_google
	done
	cat $tmp_ip_google | \
    sort | uniq | \
    xargs -r \
    > $_ip_google	
fi
if [ $app -eq 1 ];then
	for domain in \
				captive.apple.com \
				www.apple.com \
				www.icloud.com 
	do
		# with client subnet
		nslookup $domain 8.8.8.8 | \
			grep 'Address ' | \
			grep -v '127\.0\.0\.1' | \
			grep -v '8\.8\.8\.8' | \
			grep -v '0\.0\.0\.0' | \
			awk '{print $3}' | \
			grep -v ':' >> $tmp_ip_apple
	done
	cat $tmp_ip_apple | \
    sort | uniq | \
    xargs -r \
    > $_ip_apple	
fi
if [ $ms -eq 1 ];then
	
	for domain in \
				windowsphone.com \
				www.windowsphone.com \
				www.microsoft.com \
				microsoft.com 
	do
		# with client subnet
		nslookup $domain 8.8.8.8 | \
			grep 'Address ' | \
			grep -v '127\.0\.0\.1' | \
			grep -v '8\.8\.8\.8' | \
			grep -v '0\.0\.0\.0' | \
			awk '{print $3}' | \
			grep -v ':' >> $tmp_ip_microsoft
	done
	cat $tmp_ip_microsoft | \
    sort | uniq | \
    xargs -r \
    > $_ip_microsoft	

fi

/etc/init.d/chilli stop
sleep 5 && /etc/init.d/chilli start
