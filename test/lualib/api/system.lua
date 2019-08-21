local config = require "config"
local systemd = require "meiru.lib.systemd"

local exports = {}

function exports.index(req, res)
	local what = req.params.what
	local page = req.query.page
	local limit = req.query.limit
	local retval
	if what == "network" then
		local data = systemd.net_stat(page, limit)
		retval = {
			code  = 0,
			msg   = "",
			count = #data,
			data  = data,
		}
	elseif what == "service" then
		local data = systemd.service_stat(page, limit)
		local stat = systemd.mem_stat()
		retval = {
			code  = 0,
			msg   = "",
			count = #data,
			data  = data,
			total = stat.total,
			block = stat.block
		}
	elseif what == "visit" then
		local data = systemd.client_stat()
		retval = {
			code  = 0,
			msg   = "",
			count = #data,
			data  = data,
			addr  = req.addr
		}
	end
	return res.json(retval)
end

return exports

