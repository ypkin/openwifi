--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

require("luci.sys")
local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()

m = Map("wifimedia",translate(""))
m.apply_on_parse = true
function m.on_apply(self)
		luci.util.exec("/sbin/wifimedia/captive_portal.sh config_captive_portal >/dev/null")
end

s = m:section(TypedSection, "nodogsplash", "")
s.anonymous = true
s.addremove = false
--s:option( Value, "ndsname","Name")
--s:option( Value, "nds_apkey","APKEY")
s:tab("basic","General Setup")
s:tab("advance","Advanced")
s:tab("network","Network")
service = s:taboption( "basic",Flag, "enable_cpn","Captive Portal Sevice","On/Off")
service.rmempty = false

network = s:taboption( "basic",ListValue, "network","Interface")
network:value("br-hotspot", "Hotspot")
network:value("br-lan", "LAN")
url = s:taboption( "basic",Value, "domain","Captive portal url","portal.nextify.vn/splash")
--url.rmempty = true
--url:depends({enable_cpn="1"})

--s:taboption( "basic",Value, "redirecturl","Redirect URL","https://google.com.vn")
pre = s:taboption( "basic",Value, "preauthenticated_users","Walled Garden","google.com.vn, vnexpress.net")
--pre:depends({enable_cpn="1"})
mac = s:taboption( "advance",Value, "maxclients","Maxclients","Max Clients:250")
mac:depends({enable_cpn="1"})
prau = s:taboption( "advance",Value, "preauthidletimeout","Preauthidletimeout","Default: > 30 Mins")
prau:depends({enable_cpn="1"})
auth = s:taboption( "advance",Value, "authidletimeout","Authidletimeout","Default: > 120 Mins")
auth:depends({enable_cpn="1"})
ses = s:taboption( "advance",Value, "sessiontimeout","Sessiontimeout","Default : 120 Mins")
ses:depends({enable_cpn="1"})
chk = s:taboption( "advance",Value, "checkinterval","Checkinterval","Default: 10 Mins")
chk:depends({enable_cpn="1"})
fb = s:taboption( "basic",Flag, "facebook","Bypass Facebook")
fb:depends({enable_cpn="1"})
--s:taboption( "basic",Flag, "https","Bypass https")
dhcpextension = s:taboption( "basic",Flag, "dhcpextension","DHCP Extension")
dhcpextension.rmempty = false
dhcpextension:depends({enable_cpn="1"})

cpn = s:taboption( "basic",Flag, "cpnurl","CPN Clients detect")
cpn.rmempty = false
cpn:depends({enable_cpn="1"})
--network:depends({enable_cpn="1"})
--[[On/Off Service]]--
function service.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set nodogsplash.@nodogsplash[0].enabled='1' && uci commit nodogsplash")
		luci.util.exec("echo '' >/etc/crontabs/roots")
		luci.util.exec("crontab /etc/cron_nds -u nds && /etc/init.d/cron restart")
		luci.util.exec("/etc/init.d/nodogsplash enable")
	else
		luci.sys.exec("uci set nodogsplash.@nodogsplash[0].enabled='0' && uci commit nodogsplash")
		luci.util.exec("echo '* * * * * /sbin/wifimedia/controller.sh heartbeat' >/etc/crontabs/roots")
		luci.util.exec("echo ''>/etc/crontabs/nds && /etc/init.d/cron restart")
		luci.util.exec("/etc/init.d/nodogsplash disable && /etc/init.d/nodogsplash stop")	
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function service.remove() end

function cpn.write(self, section, value)
if value == self.enabled then
		luci.util.exec("crontab /etc/cron_nds -u nds && /etc/init.d/cron restart")
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function cpn.remove() end
	
function dhcpextension.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set network.local='interface'")
		luci.sys.call("uci set network.local.proto='relay'")
		luci.sys.call("uci commit")
	else
		luci.sys.call("uci del network.local")
		luci.sys.call("uci commit")
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function dhcpextension.remove() end


local pid = luci.util.exec("pidof nodogsplash")
local message = luci.http.formvalue("message")

function captive_process_status()
  local status = "Captive portal is not running"

  if pid ~= "" then
      --status = "Captive portal is running PID: "..pid.. ""
	  status = "Captive portal is running"
  end

  if nixio.fs.access("/etc/rc.d/S95nodogsplash") then
    status = status .. ""
  else
    status = status .. ""
  end

  local status = { status=status, message=message }
  local table = { pid=status }
  return table
end

t = m:section(Table, captive_process_status())
t.anonymous = true

t:option(DummyValue, "status","Captive portal status")
--[[
	if nixio.fs.access("/etc/rc.d/S95nodogsplash") then
	  disable = t:option(Button, "_disable","Disable Startup")
	  disable.inputstyle = "remove"
	  function disable.write(self, section)
			luci.sys.exec("uci set nodogsplash.@nodogsplash[0].enabled='0' && uci commit nodogsplash")
			luci.util.exec("echo '* * * * * /sbin/wifimedia/controller.sh heartbeat' >/etc/crontabs/roots")
			luci.util.exec("echo ''>/etc/crontabs/nds && /etc/init.d/cron restart")
			luci.util.exec("/etc/init.d/nodogsplash disable && /etc/init.d/nodogsplash stop")
			luci.http.redirect(
            		luci.dispatcher.build_url("admin", "services", "wifimedia_portal")
			)			
	  end
	else
	  enable = t:option(Button, "_enable","Enable Startup")
	  enable.inputstyle = "apply"
	  function enable.write(self, section)
			luci.sys.call("uci set nodogsplash.@nodogsplash[0].enabled='1' && uci commit nodogsplash")
			luci.util.exec("echo '' >/etc/crontabs/roots")
			luci.util.exec("crontab /etc/cron_nds -u nds && /etc/init.d/cron restart")
			luci.util.exec("/etc/init.d/nodogsplash enable")
			luci.http.redirect(
            		luci.dispatcher.build_url("admin", "services", "wifimedia_portal")
			)			
	  end
	end
]]--
return m
