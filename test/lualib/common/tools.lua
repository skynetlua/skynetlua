local md5   = require "md5"

local tools = {}

function tools.validateId(str)
	local ret = string.match(str, "^[%w%p]+$")
	return ret and true or false
end

function tools.isEmail(email)
	return string.match(email, "[%w%p]+@[%w%p]+")
end

function tools.md5(str)
	return md5.sumhexa(str)
end

function tools.bhash(str)
	return md5.sumhexa(str)
end

function tools.bcompare(str, hash)
	local str = md5.sumhexa(str)
	return str == hash
end

return tools