--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.lte", package.seeall)
function index()
	entry( { "admin", "network", "lte" }, cbi("wifimedia_module/lte"), _("4G LTE"),      15)
end
