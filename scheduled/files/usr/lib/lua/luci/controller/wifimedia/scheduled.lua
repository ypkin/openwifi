module("luci.controller.wifimedia.scheduled", package.seeall)
function index()
		--entry({"admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
		entry({"admin", "services","scheduled"}, cbi("wifimedia_module/scheduled"), "Schedule Tasks", 65)
end

