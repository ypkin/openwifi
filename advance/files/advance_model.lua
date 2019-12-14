--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local wfm_lcs = fs.access("/etc/opt/wfm_lcs")
local license = fs.access("/etc/opt/first_time.txt")
local next_net = luci.util.exec("uci -q get network.nextify")
local detect_5g = luci.util.exec("uci -q get wireless.radio0.hwmode")
m = Map("wifimedia", "")
m.apply_on_parse = true
function m.on_apply(self)
	if license then
		luci.sys.call("env -i /sbin/wifimedia/controller.sh license_local >/dev/null")
	end
	--luci.sys.call("env -i /sbin/wifimedia/controller_local.sh local_config >/dev/null")
	luci.sys.call("env -i /bin/ubus call network reload >/dev/null 2>/dev/null")
	--luci.http.redirect(luci.dispatcher.build_url("admin","wifimedia","advance"))
end

s = m:section(TypedSection, "wireless","")
s.anonymous = true
s.addremove = false
--[[
s:tab("radio24","24G Wireless")
ctrgs_en = s:taboption("radio24",Flag, "bw24g", "2.4 Enable")
ctrgs = s:taboption("radio24",Value, "essid", "SSID")
ctrgs:depends({bw24g="1"})

ctrgsm = s:taboption("radio24",ListValue, "mode", "MODE")
ctrgsm:value("ap","AP")
ctrgsm:value("mesh","MESH")
ctrgsm:value("wds","WDS")
ctrgsm:depends({bw24g="1"})

ch = s:taboption( "radio24",ListValue, "channel", "Channel")
local channel = 1
while (channel < 14) do
	ch:value(channel, channel .. " ")
	channel = channel + 1
end
ch.default = "6"
ch:depends({bw24g="1"})

ctrgscnl = s:taboption("radio24",Value, "maxassoc", "Connection Limit")
ctrgscnl:depends({bw24g="1"})

ctrgsn = s:taboption("radio24",ListValue, "network", "Network")
ctrgsn:value("wan","WAN")
ctrgsn:value("lan","LAN")
ctrgsn:value("vlanx24","VLAN")
vlanx = s:taboption("radio24",Value,"vlan24g","VLAN")
vlanx:depends({network="vlanx24"})
if next_net ~= "" then
	ctrgsn:value("nextify","Nextify")
end
ctrgsn:depends({bw24g="1"})

ctrgsn = s:taboption("radio24",ListValue, "encrypt", "Wireless Security")
ctrgsn:value("","No Encryption")
ctrgsn:value("encryption","WPA-PSK/WPA2-PSK")
ctrgsn:depends({bw24g="1"})

grwpa = s:taboption("radio24",Value, "password", "Password")
grwpa.datatype = "wpakey"
grwpa.rmempty = true
grwpa.password = true
grwpa:depends({encrypt="encryption"})

ctrgsft = s:taboption("radio24",ListValue, "ft", "Fast Roaming")
ctrgsft:value("rsn_preauth","Fast-Secure Roaming")
ctrgsft:value("ieee80211r","Fast Basic Service Set Transition (FT)")
ctrgsft:depends({encrypt="encryption"})

pmk = s:taboption("radio24",Flag,"ft_psk_generate_local","Generate PMK Locally")
pmk:depends({ft="ieee80211r"})
pmk.rmempty = false

nasid = s:taboption("radio24",Value, "nasid", "NAS ID")
nasid:depends({ft="ieee80211r"})
device = s:taboption("radio24",Value, "macs", "APID")
device:depends({ft="ieee80211r", ft_psk_generate_local=""})
--macs.datatype = "macaddr"

ctrgtx = s:taboption("radio24",ListValue, "txpower", "Transmit Power")
ctrgtx:value("auto","Auto")
ctrgtx:value("low","Low")
ctrgtx:value("medium","Medium")
ctrgtx:value("high","High")
ctrgtx:depends({bw24g="1"})

hidessid = s:taboption("radio24",Flag, "hidessid","Hide SSID")
hidessid.rmempty = false
hidessid:depends({bw24g="1"})
 
apisolation = s:taboption("radio24",Flag, "isolation","AP Isolation")
apisolation.rmempty = false
apisolation:depends({bw24g="1"})

--s = m:section(TypedSection, "radio5","")
s:tab("radio5","5G Wireless")
ctrgs_en = s:taboption("radio5",Flag, "bw5g", "5G Enable")
ctrgs = s:taboption("radio5",Value, "essidfive", "SSID")
ctrgs:depends({bw5g="1"})

ctrgsm = s:taboption("radio5",ListValue, "modefive", "MODE")
ctrgsm:value("ap","AP")
ctrgsm:value("mesh","MESH")
ctrgsm:value("wds","WDS")
ctrgsm:depends({bw5g="1"})

ch = s:taboption( "radio5",ListValue, "channelfive", "Channel")
ch:value("36","36 (low power)")
ch:value("40","40 (low power)")
ch:value("36","36 (low power)")
ch:value("44","44 (low power)")
ch:value("48","48 (low power)")
ch:value("52","52 (DFS)")
ch:value("56","56 (DFS)")
ch:value("60","60 (DFS)")
ch:value("64","64 (DFS)")
ch:value("100","100 (high power)")
ch:value("104","104 (high power)")
ch:value("108","108 (high power)")
ch:value("112","112 (high power)")
ch:value("116","116 (high power)")
ch:value("120","120 (high power)")
ch:value("124","124 (high power)")
ch:value("128","128 (high power)")
ch:value("132","132 (high power)")
ch:value("136","136 (high power)")
ch:value("140","140 (high power)")
ch:value("149","149 (high power)")
ch:value("153","153 (high power)")
ch:value("157","157 (high power)")
ch:value("161","161 (high power)")
ch:value("165","165 (high power)")
ch:depends({bw5g="1"})

ctrgscnl = s:taboption("radio5",Value, "maxassocfive", "Connection Limit")
ctrgscnl:depends({bw5g="1"})

ctrgsn = s:taboption("radio5",ListValue, "networkfive", "Network")
ctrgsn:value("wan","WAN")
ctrgsn:value("lan","LAN")
ctrgsn:value("vlanx5","VLAN")
vlanx5 = s:taboption("radio5",Value,"vlan5g","VLAN")
vlanx5:depends({networkfive="vlanx5"})
if next_net ~= "" then
	ctrgsn:value("nextify","Nextify")
end
ctrgsn:depends({bw5g="1"})

ctrgsn = s:taboption("radio5",ListValue, "encryptfive", "Wireless Security")
ctrgsn:value("","No Encryption")
ctrgsn:value("encryptionfive","WPA-PSK/WPA2-PSK")
ctrgsn:depends({bw5g="1"})

grwpa = s:taboption("radio5",Value, "passwordfive", "Password")
grwpa.datatype = "wpakey"
grwpa.rmempty = true
grwpa.password = true
grwpa:depends({encryptfive="encryptionfive"})

ctrgsft = s:taboption("radio5",ListValue, "ftfive", "Fast Roaming")
ctrgsft:value("rsn_preauthfive","Fast-Secure Roaming")
ctrgsft:value("ieee80211rfive","Fast Basic Service Set Transition (FT)")
ctrgsft:depends({encryptfive="encryptionfive"})

pmk = s:taboption("radio5",Flag,"ft_psk_generate_localfive","Generate PMK Locally")
pmk:depends({ftfive="ieee80211rfive"})
pmk.rmempty = false

nasid = s:taboption("radio5",Value, "nasidfive", "NAS ID")
nasid:depends({ftfive="ieee80211rfive"})
device = s:taboption("radio5",Value, "macsfive", "APID")
device:depends({ftfive="ieee80211rfive", ft_psk_generate_localfive=""})
--macs.datatype = "macaddr"

ctrgtx = s:taboption("radio5",ListValue, "txpowerfive", "Transmit Power")
ctrgtx:value("autofive","Auto")
ctrgtx:value("lowfive","Low")
ctrgtx:value("mediumfive","Medium")
ctrgtx:value("highfive","High")
ctrgtx:depends({bw5g="1"})

hidessid = s:taboption("radio5",Flag, "hidessidfive","Hide SSID")
hidessid.rmempty = false
hidessid:depends({bw5g="1"})
 
apisolation = s:taboption("radio5",Flag, "isolationfive","AP Isolation")
apisolation.rmempty = false
apisolation:depends({bw5g="1"})
]]--
--[[
s:tab("bridge_network",  translate("Bridge Network"))
bridge_mode = s:taboption("bridge_network", Flag, "bridge_mode","Bridge","Ethernet:  wan => lan")
bridge_mode.rmempty = false
		function bridge_mode.write(self, section, value)
			if value == self.enabled then
				luci.sys.call("uci delete network.lan")
				luci.sys.call("uci set network.wan.proto='dhcp'")
				luci.sys.call("uci set network.wan.ifname='eth0 eth1.1'")
				luci.sys.call("uci set wireless.@wifi-iface[0].network='wan'")
				luci.sys.call("uci commit")
			else
			    luci.sys.call("uci set network.lan='interface'")
				luci.sys.call("uci set network.lan.proto='static'")
				luci.sys.call("uci set network.lan.ipaddr='172.16.99.1'")
				luci.sys.call("uci set network.lan.netmask='255.255.255.0'")
				luci.sys.call("uci set network.lan.type='bridge'")
				luci.sys.call("uci set network.lan.ifname='eth1.1'")
				luci.sys.call("uci set dhcp.lan.force='1'")
				luci.sys.call("uci set dhcp.lan.netmask='255.255.255.0'")
				luci.sys.call("uci del dhcp.lan.dhcp_option")
				luci.sys.call("uci add_list dhcp.lan.dhcp_option='6,8.8.8.8,8.8.4.4'")				
				luci.sys.call("uci set network.wan.ifname='eth0'")
				luci.sys.call("uci set wireless.@wifi-iface[0].network='wan'")
				luci.sys.call("uci commit")		
			end
			return Flag.write(self, section, value)
		end
		function bridge_mode.remove() end
]]--		
--RSSI--
s:tab("rssi",  translate("RSSI"))
	--s:taboption("rssi", Value, "pinginterval","Interval (s)").placeholder = "interval"
	rssi = s:taboption("rssi", Flag, "enable","Enable")
	rssi.rmempty = false
		function rssi.write(self, section, value)
			if value == self.enabled then
				luci.sys.call("env -i /etc/init.d/watchcat start >/dev/null")
				luci.sys.call("env -i /etc/init.d/watchcat enable >/dev/null")
			else
				luci.sys.call("env -i /etc/init.d/watchcat stop >/dev/null")
				luci.sys.call("env -i /etc/init.d/watchcat disable >/dev/null")
			end
			return Flag.write(self, section, value)
		end
		function rssi.remove() end
	--else 
	--	m.pageaction = false

	t = s:taboption("rssi", Value, "level","RSSI:","Received signal strength indication: Range:-60dBm ~ -90dBm")
	t.datatype = "min(-90)"
	--s:taboption("rssi",Value, "delays","Time Delays (s)").optional = false
	--t:depends({enable="1"})
--[[END RSSI]]--		
--License
if wfm_lcs then
	s:tab("license",  translate("Activation code"))
	wfm = s:taboption("license",Value,"wfm","Activation code")
	wfm.rmempty = true
end
--[[END LICENS]]--
return m
