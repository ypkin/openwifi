--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

require("luci.sys")
local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local ssid0= luci.util.exec("uci get wireless.@wifi-iface[0].ssid")
local ssid1= luci.util.exec("uci get wireless.@wifi-iface[1].ssid")

m = Map("wifimedia",translate(""))

m.apply_on_parse = true
function m.on_apply(self)
		luci.util.exec(" sleep 9 && reboot ")
end
s = m:section(TypedSection, "hotspot","")
s.anonymous = true
s.addremove = false

s:tab("ld_page","Landing Page")
s:tab("network","Network")
s:tab("wg","Walled Garden")

s:taboption("ld_page", Value, "nasid", "NASID")
s:taboption("ld_page", Value, "uamsecret", "APKEY")
s:taboption("ld_page", Value, "uamformat", "Login Splash Page")
s:taboption("ld_page", Value, "uamdomain", "Walled Garden Domain")
s:taboption("ld_page", Value, "uamallow", "Walled Garden IP")
--tab network--
eth = s:taboption("network", ListValue, "lan","Interface")
eth:value("wlan0",ssid0 .. "")
eth:value("wlan0-1",ssid1 .. "")
eth:value("br-lan", "LAN")
s:taboption("network", Value, "radius01","Radius Server01")
s:taboption("network", Value, "radius02","Radius Server01")
------------------------
facebook = s:taboption("wg", Flag, "facebook","Facebook")
facebook.rmempty = false
google = s:taboption("wg", Flag, "google","Google")
google.rmempty = false
iphone = s:taboption("wg", Flag, "iphone","Apple")
iphone.rmempty = false
windowsphone = s:taboption("wg", Flag, "windowsphone","Windows")
windowsphone.rmempty = false
---Function---
function facebook.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set wifimedia.@hotspot[0].facebook_dns='m.facebook.com/v2.4/dialog/share?app_id=881773835231214 connect.facebook.net fbstatic-a.akamaihd.net staticxx.facebook.com web.facebook.com z-1-static.xx.fbcdn.net .facebook.com .m.facebook.com .akamaihd.net .facebook.net .akamaihd.net .dspw41.akamai.net'")
	else
		luci.sys.call("uci delete  wifimedia.@hotspot[0].facebook_dns")
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function facebook.remove() end

function google.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set wifimedia.@hotspot[0].google_dns='.google.com .google.com.vn accounts.google.com googleapis.com gmail.com picasa.google.com gstatic.com googleusercontent.com .youtube.com m.youtube.com .google.android.youtube youtube.com googlevideo.com .ytimg.com  com.google.android.youtube'")
	else
		luci.sys.call("uci delete  wifimedia.@hotspot[0].google_dns")
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function google.remove() end

function windowsphone.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set wifimedia.@hotspot[0].windowsphone_dns='.windowsphone.com'")
	else
		luci.sys.call("uci delete  wifimedia.@hotspot[0].windowsphone_dns")
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function windowsphone.remove() end

function iphone.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set wifimedia.@hotspot[0].iphone_dns='captive.apple.com'")
	else
		luci.sys.call("uci delete  wifimedia.@hotspot[0].iphone_dns")
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function iphone.remove() end

-----------------------------------------

local pid = luci.util.exec("pidof chilli")
local message = luci.http.formvalue("message")

function hotspot_process_status()
  local status = "Hotspot is not running now and "

  if pid ~= "" then
      status = "Hotspot is running PID: "..pid.. "and "
  end

  if nixio.fs.access("/etc/rc.d/S99wifi_portal") then
    status = status .. "it's enabled on the startup"
  else
    status = status .. "it's disabled on the startup"
  end

  local status = { status=status, message=message }
  local table = { pid=status }
  return table
end

t = m:section(Table, hotspot_process_status())
t.anonymous = true

t:option(DummyValue, "status","Hotspot status")

if nixio.fs.access("/etc/rc.d/S99wifi_portal") then
  disable = t:option(Button, "_disable","Disable from startup")
  disable.inputstyle = "remove"
  function disable.write(self, section)
		luci.util.exec("/etc/init.d/update_ip disable")
		luci.util.exec("/etc/init.d/wifi_portal disable")
		luci.util.exec("/etc/init.d/wifi_portal stop && /etc/init.d/network restart")
		luci.http.redirect(
        		luci.dispatcher.build_url("admin", "services", "hotspot")
		)
  end
else
  enable = t:option(Button, "_enable","Enable on startup")
  enable.inputstyle = "apply"
  function enable.write(self, section)
		luci.util.exec("/etc/init.d/update_ip enable")
		luci.util.exec("/etc/init.d/wifi_portal enable")
		luci.http.redirect(
        		luci.dispatcher.build_url("admin", "services", "hotspot")
		)
  end
end

return m
