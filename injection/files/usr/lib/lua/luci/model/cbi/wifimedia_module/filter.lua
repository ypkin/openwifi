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
		luci.util.exec("/usr/bin/adnetwork_local.sh start")
end
s = m:section(TypedSection, "adnetwork","")
s.anonymous = true
s.addremove = false

--s:tab("adnetwork_cfg","Cloud")
--s:tab("chatbot","Chatbot")
--s:tab("fb","Facebook")
--s:tab("youtube","Youtube")
s:tab("image","Image")
s:tab("adv","Advanced")

--s:taboption("adnetwork_cfg", Value, "domain","Domain").placeholder = "exp: .vnexpress.net, ..."
--s:taboption("adnetwork_cfg", Value,"gw","APkey").placeholder = "APKEY"
--s:taboption("chatbot", Value,"facebook_id","Facebook ID").placeholder = "Facebook ID"
--s:taboption("chatbot", Value,"ref","Messenger").placeholder = "User ID: vnpictures"
--s:taboption("youtube", Value,"youtube","Youtube").placeholder = "Video ID: X8AOQRz6m8Q"

s:taboption("image", Value,"img1","Link1 image")
url_web=s:taboption("image", Value,"link1","Link1 website")

s:taboption("image", Value,"img2","Link2 image")
url_web=s:taboption("image", Value,"link2","Link2 website")

s:taboption("image", Value,"img3","Link3 image")
url_web=s:taboption("image", Value,"link3","Link3 website")

s:taboption("image", Value,"img4","Link4 image")
url_web=s:taboption("image", Value,"link4","Link4 website")

s:taboption("image", Value,"img5","Link5 image")
url_web=s:taboption("image", Value,"link5","Link5 website")

--ads_image = s:taboption("image", Flag,"ads_image_status","Status")
rd_image = s:taboption("image", Flag,"random_image_status","Random Option")
--rd_image:depends({ads_image_status="1"})
--st_img = s:taboption("image", ListValue,"img_status","Option")
--st_img:depends({ads_image_status="1"})

--local data_img = {"Imge","Imge1","Imge2", "Imge3","Imge4" }
--for _, img_status in ipairs(data_img) do 
--	st:value(img_status, img_status .. " ")
--end

s:taboption("adv", Value, "domain_acl","Domain").placeholder = "exp: .vnexpress.net, ..."
--[[
ads_st = s:taboption("adv", Flag,"ads_status","Status")
rd = s:taboption("adv", Flag,"random_status","Random Option")
rd:depends({ads_status="1"})
]]--
st = s:taboption("adv", ListValue,"status","Option")
--st:depends({ads_status="1"})

--local data = {"Chatbot","Facebook_Page","Facebook_Videos", "Facebook_Like_Share","Youtube","Image1","Image2", "Image3","Image4","Image5" }
local data = {"Image1","Image2", "Image3","Image4","Image5" }
for _, status in ipairs(data) do 
	st:value(status, status .. " ")
end

sec = s:taboption("adv", ListValue, "second", "Second")
sec.default = "20"
--sec:depends({ads_status="1"})
local second = 9
while (second < 301) do
	sec:value(second, second .. " ")
	second = second + 1
end

--s:taboption("fb", Value,"ads_fb_page","Facebook Page").placeholder = "Facebook Page Url"
--s:taboption("fb", Value,"ads_fb_video","Facebook videos and Facebook live videos ").placeholder = "Facebook videos Url"
--s:taboption("fb", Value,"ads_fb_like","Facebook Like & Share").placeholder = "Facebook Like & Share Url"

local pid = luci.util.exec("pidof privoxy")
local message = luci.http.formvalue("message")

function advertis_network_process_status()
  local status = "Filter is not running"

  if pid ~= "" then
      status = "Filter is running PID: "..pid.. " "
  end

  if nixio.fs.access("/etc/rc.d/80privoxy") then
    status = status .. ""
  else
    status = status .. ""
  end

  local status = { status=status, message=message }
  local table = { pid=status }
  return table
end

t = m:section(Table, advertis_network_process_status())
t.anonymous = true

t:option(DummyValue, "status","Filter status")

if nixio.fs.access("/etc/rc.d/S80privoxy") then
  disable = t:option(Button, "_disable","Disable")
  disable.inputstyle = "remove"
  function disable.write(self, section)
		luci.util.exec("echo ''>/etc/crontabs/adnetwork && /etc/init.d/cron restart")
		luci.util.exec("/etc/init.d/privoxy disable")
		luci.util.exec(" /etc/init.d/privoxy  stop && /etc/init.d/firewall restart")
		luci.http.redirect(
        		luci.dispatcher.build_url("admin", "services", "filter")
		)			
  end
else
  enable = t:option(Button, "_enable","Enable")
  enable.inputstyle = "apply"
  function enable.write(self, section)
		luci.util.exec("uci set privoxy.privoxy.permit_access=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'|cut -c 1,2,3,4,5,6,7,8,9,10,11)0/24:8118 && uci commit privoxy")
		luci.util.exec("uci set privoxy.privoxy.listen_address=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'):8118 && uci commit privoxy")
		luci.util.exec("/etc/init.d/privoxy enable")
		luci.util.exec(" /etc/init.d/privoxy start ")
		luci.util.exec("crontab /etc/cron_ads -u adnetwork && /etc/init.d/cron restart")
		luci.http.redirect(
        		luci.dispatcher.build_url("admin", "services", "filter")
		)			
  end
end
return m
