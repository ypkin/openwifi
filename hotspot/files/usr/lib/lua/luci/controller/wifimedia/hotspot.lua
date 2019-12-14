--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.hotspot", package.seeall)
function index()
	--entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "services", "hotspot" }, cbi("wifimedia_module/hotspot"), _("Hotspot"),      20)
end