
local exports = {}

function exports.render(req, res)
	
	res.render404 = function(body)
		res.status(404)
		return res.render('notify/notify', {the_error = body, referer=req.get('referer')})
    end

    res.render403 = function(body)
        log("req =", req)
        res.status(403)
		return res.render('notify/notify', {the_error = body, referer=req.get('referer')})
    end

    res.renderCode = function(code, body)
        res.status(code)
		return res.render('notify/notify', {the_error = body, referer=req.get('referer')})
    end
end

return exports
