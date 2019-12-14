--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.switchmode", package.seeall)
function index()
	--entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "services", "switchmode" }, cbi("wifimedia_module/switchmode"), _("Ethernet switch "),      15)
end
