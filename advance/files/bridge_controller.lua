--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.bridge", package.seeall)
function index()
	--entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "wifimedia", "bridge" }, cbi("wifimedia_module/bridge"), _("Bridge Network"),      15)
end