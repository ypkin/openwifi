-- Copyright 2016 Dirk van der Walt <dirk@mymail.com>
-- Licensed to the public under the Apache License 2.0.
 
module("luci.controller.meshdesk", package.seeall)
 
function index()
        local cc
        cc = entry( { "admin", "system", "meshdesk" },       cbi("meshdesk"),         _("Cloud Controller"),                90)
end
