local skynet = require "skynet"

local fuckforbid = {}
setmetatable(fuckforbid, {__index = function(t,cmd)
    local f = function(...)
        return skynet.call(".fuckforbid", "lua", cmd, ...)
    end
    t[cmd] = f
    return f
end})


return fuckforbid

