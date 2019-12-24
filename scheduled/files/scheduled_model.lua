local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
m = Map("scheduled", "Auto Reboot ")
m.apply_on_parse = true
function m.on_apply(self)
		luci.util.exec(" /usr/bin/scheduled.sh start ")
end


s = m:section(TypedSection, "instance", "Days")
s.template  = "cbi/tblsection"
s.anonymous = true
s.addremove = false
--[[
Everyday = s:option(Flag, "Everyday","Everyday")
Everyday.rmempty = false
 ]]--
--Monday
Mon = s:option(Flag, "Mon","Mon")
Mon.rmempty = false
--Mon:depends({Everyday="1"})

--Tuesday
Tue = s:option(Flag, "Tue","Tue")
Tue.rmempty = false

--Wednesday
Wed = s:option(Flag, "Wed","Wed")
Wed.rmempty = false

--Thursday
Thu = s:option(Flag, "Thu","Thu")
Thu.rmempty = false

--Friday
Fri = s:option(Flag, "Fri","Fri")
Fri.rmempty = false

--Satturday
Sat = s:option(Flag, "Sat","Sat")
Sat.rmempty = false

--Sunday
Sun = s:option(Flag, "Sun","Sun")
Sun.rmempty = false

t = m:section(TypedSection, "times", "Times ")
t.anonymous = true
t.addremove = false
h = t:option(ListValue, "hour", "Hours")
local time = 0
while (time < 24) do
	h:value(time, time .. " ")
	time = time + 1
end

mi = t:option( ListValue, "minute", "Minutes")
local minute = 0
while (minute < 60) do
	mi:value(minute, minute .. " ")
	minute = minute + 1
end

return m
