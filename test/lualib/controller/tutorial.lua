local config = require "config"

local exports = {}

function exports.index(req, res)
	res.set_layout(nil)
    return res.render('tutorial/index', {})
end


return exports

