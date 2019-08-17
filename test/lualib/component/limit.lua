local cached = require "meiru.db.cached"
local config = require "config"

local exports = {}

local kMSeparator = '^_^@T_T'
local function makePerDayLimiter(identityName, identityFn)
    return function(name, limitCount, options)
        return function(req, res)
            local identity = identityFn(req)
            local dkey  = os.date("%Y%m%d")
            local key   = dkey ..kMSeparator ..identityName ..kMSeparator ..name ..kMSeparator ..identity
            local count = tonumber(cached.get(key)) or 0
            if count < limitCount then
                count = count+1
                cached.set(key, count, 60 * 60 * 24)
                res.set('X-RateLimit-Limit', limitCount)
                res.set('X-RateLimit-Remaining', limitCount - count)
            else
                res.status(403)
                if options.showJson then
                    res.send({success = false, error_msg = '频率限制：当前操作每天可以进行 '..limitCount..' 次'})
                    return true
                else
                    res.render('notify/notify', {the_error = '频率限制：当前操作每天可以进行 '..limitCount..' 次'})
                    return true
                end
            end
        end
    end
end

exports.peruserperday = makePerDayLimiter('peruserperday', function(req)
    if not req.session or not req.session.user then
        error('should provide `x-real-ip` header')
    end
    return req.session.user.loginname
end)

exports.peripperday = makePerDayLimiter('peripperday', function(req)
    local realIP = req.ip
    if not realIP and not config.debug then
        error('should provide `x-real-ip` header')
    end
    return realIP
end)


return exports

