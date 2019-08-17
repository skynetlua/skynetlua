local exports = {}

function exports.index(req, res)
	local q = req.query.q
	q = string.urlencode(q)
    return res.redirect("https://www.google.com.hk/#hl=zh-CN&q=site:skynetlua.com+"..q)
end

return exports

