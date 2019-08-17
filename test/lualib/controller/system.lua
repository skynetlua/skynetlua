local skynet = require "skynet"
local config = require "config"

local exports = {}

function exports.index(req, res)
	local ws_url = "ws://"..req.get('host').."/"
	res.set_layout(nil)
    return res.render('system/index', {ws_url = ws_url})
end

return exports

