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
		luci.util.exec("/sbin/wifimedia/preauthenticated_rules.sh >/dev/null")
		--luci.util.exec("/etc/init.d/network reload >/dev/null")
		--luci.util.exec("sleep 15 && reboot >/dev/null")
end

s = m:section(TypedSection, "nodogsplash", "")
s.anonymous = true
s.addremove = false
--s:option( Value, "ndsname","Name")
--s:option( Value, "nds_apkey","APKEY")
s:tab("basic","Basic")
s:tab("advance","Advanced")
s:tab("network","Network")
--s:taboption( "basic",Value, "domain","Nextify portal","portal.nextify.vn/splash")
--s:taboption( "basic",Value, "redirecturl","Redirect URL","https://google.com.vn")
s:taboption( "basic",Value, "preauthenticated_users","Walled Garden","google.com.vn, vnexpress.net")
s:taboption( "advance",Value, "maxclients","Maxclients","Max Clients:250")
s:taboption( "advance",Value, "preauthidletimeout","Preauthidletimeout","Default: > 30 Mins")
s:taboption( "advance",Value, "authidletimeout","Authidletimeout","Default: > 120 Mins")
s:taboption( "advance",Value, "sessiontimeout","Sessiontimeout","Default : 120 Mins")
s:taboption( "advance",Value, "checkinterval","Checkinterval","Default: 10 Mins")
s:taboption( "basic",Flag, "facebook","Bypass Facebook")
s:taboption( "basic",Flag, "https","Bypass https")
dhcpextension = s:taboption( "basic",Flag, "dhcpextension","DHCP Extension")
dhcpextension.rmempty = false
		
function dhcpextension.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set network.local='interface'")
		luci.sys.call("uci set network.local.proto='relay'")
		luci.sys.call("uci set network.local.ipaddr='172.16.99.1'")
		--luci.sys.call("uci add_list network.local.network='lan'")
		--luci.sys.call("uci add_list network.local.network='wan'")
		luci.sys.call("uci set dhcp.lan.ignore='1'")
		luci.sys.call("uci set wireless.@wifi-iface[0].network='lan'")
		--luci.sys.call("uci set nodogsplash.@nodogsplash[0].gatewayinterface='br-lan'")
	else
		luci.sys.call("uci del network.local")
		luci.sys.call("uci set dhcp.lan.ignore='0'")
		luci.sys.call("uci set wireless.@wifi-iface[0].network='lan'")
		--luci.sys.call("uci set nodogsplash.@nodogsplash[0].gatewayinterface='br-private'")
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

	if nixio.fs.access("/etc/rc.d/S95nodogsplash") then
	  disable = t:option(Button, "_disable","Disable Startup")
	  disable.inputstyle = "remove"
	  function disable.write(self, section)
			--luci.util.exec("/sbin/wifimedia/del_network_nds.sh")
			luci.sys.exec("uci set nodogsplash.@nodogsplash[0].enabled='0' && uci commit nodogsplash")
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
			--luci.util.exec("/sbin/wifimedia/preauthenticated_rules.sh")
			luci.sys.call("uci set nodogsplash.@nodogsplash[0].enabled='1' && uci commit nodogsplash")
			luci.util.exec("crontab /etc/cron_nds -u nds && /etc/init.d/cron restart")
			luci.util.exec("/etc/init.d/nodogsplash enable")
			luci.http.redirect(
            		luci.dispatcher.build_url("admin", "services", "wifimedia_portal")
			)			
	  end
	end

return m
