local config = require "config"

local exports = {}


function exports.index(req, res)
	local tab = req.query.tab
	local item = req.query.item	
	res.set_layout(nil)
    return res.render('system/index', {
    	cur_tab  = tab,
    	cur_item = item,
    })
end

return exports

