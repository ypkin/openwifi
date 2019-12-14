require("luci.sys")
local sys = require "luci.sys"
local uci 	= require("uci")

m = Map("meshdesk", translate("Cloud Controller"), translate("Supply the following details"))
m.apply_on_parse = true 
        d = m:section(NamedSection,"settings", "settings","Activation" )  -- info is the section called info in cbi_file
                a = d:option(ListValue, "mode", "Mode");
                a.optional=false;
                a.rmempty = false;
                a:value("off","OFF");
                --a:value("mesh","Mesh");
                a:value("ap","AP");
 
        local s_internet = m:section(NamedSection,"internet1","internet","Settings");
                local protocol = s_internet:option(ListValue,"protocol", "Protocol");
                protocol:value("http","HTTP");
                protocol:value("https","HTTPS");
                --local ip = s_internet:option(Value,'ip','IP Address','IP Address of Cloud Controller');
				local dns = s_internet:option(Value,'dns','DNS Address','DNS Address of Cloud Controller');
 
m.on_parse = function(self)
        -- all written config names are in self.parsechain
        local current_mode = uci.get("meshdesk", "settings", "mode");
        local new_mode  = a:formvalue("settings")
        if(current_mode ~= new_mode)then
                if(new_mode == 'off')then
                        nixio.fs.copy("/etc/MESHdesk/configs/wireless_original","/etc/config/wireless");
                        nixio.fs.copy("/etc/MESHdesk/configs/network_original","/etc/config/network");
						luci.sys.call("/etc/init.d/md_prerun disable");
				else
						
						luci.sys.call("/etc/init.d/md_prerun enable & /etc/init.d/md_prerun start ");
                end
        end
end
 
return m