
local skynet = require "skynet"
local uuid  = require "meiru.lib.uuid"
local User  = require "model.user"
local tools = require "common.tools"

local Proxy = {}

function Proxy.getUsersByNames(names)
    if type(names) ~= "table" or #names == 0 then
        return
    end
    return User.find({loginname = {['$in'] = names}})
end

function Proxy.getUserByLoginName(loginName)
    return User.findOne({loginname = loginName})
end

function Proxy.findOne(...)
    return User.findOne(...)
end

function Proxy.getUserById(id)
    id = tonumber(id)
    if not id then
        return
    end
    return User.findOne({id = id})
end

function Proxy.getUserByMail(email)
    return User.findOne({email = email})
end

function Proxy.getUsersByIds(ids)
    return User.find({id = {['$in'] = ids}})
end

function Proxy.getUserByNameAndKey(loginname, key)
    return User.findOne({loginname = loginname, retrieve_key = key})
end

function Proxy.getUsersByQuery(query, opt)
    return User.find(query, opt)
end

function Proxy.newAndSave(name, loginname, pass, email, avatar_url, active)
    local data
    if type(name) == "table" then
        data = name
        data.accessToken = uuid()
    else
        data = {
            nickname = name,
            loginname = loginname,
            pass = pass,
            email = email,
            avatar = avatar_url,
            active = active or 0,
            accessToken = uuid(),
        }
    end
    local user = User.makeModel(data)
    user:commit()
    return user
end

function Proxy.makeGravatar(email)
    return '/public/header/' .. tools.md5(email) .. '?size=48'
end

function Proxy.getGravatar(user)
    if type(user) == "string" then
        return Proxy.makeGravatar(user)
    end
    return user.avatar 
end

return Proxy