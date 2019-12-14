module("luci.controller.wifimedia.scheduled", package.seeall)
function index()
		entry({"admin", "services","scheduled"}, cbi("wifimedia_module/scheduled"), "Schedule Tasks", 65)
end

