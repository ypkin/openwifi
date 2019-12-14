--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.filter", package.seeall)
function index()
	entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "wifimedia", "filter" }, cbi("wifimedia_module/filter"), _("Filter"),      26)
end