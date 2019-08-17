local systemd = require "meiru.lib.systemd"

---------------------------------------------
--command
---------------------------------------------
local command = {}

function command:system_test()
	log("command:system_test==========>>")


end

---------------------------------------------
--request
---------------------------------------------
local request = {}

function request:system_service_stat_req(proto)
	local stat_info = systemd.service_stat()
	return stat_info
end

function request:system_net_stat_req(proto)
	local stat_info = systemd.net_stat()
	return stat_info
end

---------------------------------------------
--trigger
---------------------------------------------
local trigger = {}

function trigger:system_test()
	log("trigger:system_test==========>>")


end


return {command = command, request = request, trigger = trigger}