--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
m = Map("wifimedia", "")
m.apply_on_parse = true
function m.on_apply(self)
	--luci.sys.call("env -i /bin/ubus call network reload >/dev/null 2>/dev/null")
end

s = m:section(TypedSection, "lte","4G LTE Interface")
s.anonymous = true
s.addremove = false

lte = s:option(Flag, "4glte","4G LTE Enable ")
lte.rmempty = false
		function lte.write(self, section, value)
			if value == self.enabled then			
			    luci.sys.call("uci set network.lte='interface'")
				luci.sys.call("uci set network.lte.proto='dhcp'")
				luci.sys.call("uci set network.lte.type='bridge'")
				luci.sys.call("uci set network.lte.ifname='eth1'")
				luci.sys.call("echo 1 >/sys/class/gpio/power_usb3/value")
				luci.sys.call("sed -i 's/echo 0 >\/sys\/class\/gpio\/power_usb3\/value/echo 1 >\/sys\/class\/gpio\/power_usb3\/value/g' /etc/init.d/network_reload")
				luci.sys.call("uci commit")
			else
				luci.sys.call("uci delete network.lte")
				luci.sys.call("uci commit")
				luci.sys.call("echo 0 >/sys/class/gpio/power_usb3/value")
				luci.sys.call("sed -i 's/echo 1 >\/sys\/class\/gpio\/power_usb3\/value/echo 0 >\/sys\/class\/gpio\/power_usb3\/value/g' /etc/init.d/network_reload")
			end
			return Flag.write(self, section, value)
		end
		function lte.remove() end
return m
