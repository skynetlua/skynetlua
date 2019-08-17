local config = require "config"
-- local cjson  = require "cjson"
local UserModel = require "model.user"
local MessageProxy = require "proxy.message"
local UserProxy  = require "proxy.user"

local exports = {}

function exports.adminRequired(req, res)
    if not req.session.user then
        return res.render('notify/notify', {the_error = '你还没有登录。' })
    end
    if not req.session.user.is_admin then
        return res.render('notify/notify', {the_error = '需要管理员权限。' })
    end
end

function exports.userRequired(req, res)
    if not req.session or not req.session.user or not req.session.user.id then
        return res.render403('forbidden!')
    end
end

function exports.blockUser(req, res)
    if req.path == '/signout' then
        return
    end
    if req.session.user and req.session.user.is_block ~= 0 and req.method:upper() ~= 'GET' then
        return res.render403('您已被管理员屏蔽了。有疑问请联系skynetlua@foxmail.com。')
    end
end

function exports.authUser(req, res)
    local user = req.session.user
    if not user then
        local user_id = req.session.get(config.auth_cookie_name)
        if not user_id then
            return
        end
        user_id = tonumber(user_id)
        if not user_id then
            req.session.set(config.auth_cookie_name, nil)
            return
        end
        user = UserProxy.getUserById(user_id)
        if not user then
            log("exports.authUser no exist user_id =", user_id)
            return
        end
        -- user = UserModel.makeModel(userdata)
        req.session.user = user
    end
    --for view data
    res.data("current_user", user)
    if config.admins[user.loginname] then
        user.is_admin = true
        if user.active == 0 then
            user.active = 1
            user:save("active")
        end 
    end
    user.messages_count = MessageProxy.getMessagesCount(user.id)
end


return exports

