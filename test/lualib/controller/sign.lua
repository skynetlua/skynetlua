local skynet = require "skynet"
local config = require "config"
local tools     = require "common.tools"
local mail      = require "common.mail"
local UserProxy = require "proxy.user"
local uuid      = require "meiru.lib.uuid"

local table = table
local string = string

local exports = {}

function exports.showSignup(req, res)
    return res.render('sign/signup')
end

function exports.signup(req, res)
    local loginname = string.trim(string.lower(req.body.loginname))
    local email     = string.trim(string.lower(req.body.email))
    local pass      = string.trim(req.body.pass)
    local rePass    = string.trim(req.body.re_pass)

    local function prop_err(msg)
        res.status(422)
        res.render('sign/signup', {the_error = msg, loginname = loginname, email = email})
    end

    if loginname == "" or pass == "" or rePass == "" or email == "" then
        prop_err('信息不完整。')
        return
    end
    if #loginname < 5 then
        prop_err('用户名至少需要5个字符。')
        return
    end

    if not tools.validateId(loginname) or loginname:sub(1, 3) == "git" then
        prop_err('用户名不合法。')
        return
    end
    if not tools.isEmail(email) then
        prop_err('邮箱不合法。')
        return
    end
    if pass ~= rePass then
        prop_err('两次密码输入不一致。')
        return
    end
    local users = UserProxy.getUsersByQuery({['$or'] = {{loginname = loginname}, {email = email}}})
    if #users > 0 then
        prop_err('用户名或邮箱已被使用。')
        return
    end
    local passhash = tools.bhash(pass)
    local avatarUrl = UserProxy.makeGravatar(email)
    UserProxy.newAndSave(loginname, loginname, passhash, email, avatarUrl, false)
    mail.sendActiveMail(email, tools.md5(email .. passhash .. config.session_secret), loginname)
    return res.render('sign/signup', {
        success = '欢迎加入 ' .. config.name .. '！我们已给您的注册邮箱发送了一封邮件，请点击里面的链接来激活您的帐号。'
    })
end

function exports.showLogin(req, res)
    req.session.set('loginReferer', req.get('referer'))
    res.render('sign/signin')
end

local notJump = {
    '/active_account',
    '/reset_pass',
    '/signup', 
    '/search_pass'
}

function exports.login(req, res)
    local loginname = string.trim(string.lower(req.body.name or ''))
    local pass      = string.trim(req.body.pass or '')
    if not loginname or not pass then
        res.status(422)
        return res.render('sign/signin', {the_error = '信息不完整。'})
    end
    local getUser
    if string.find(loginname, "@", 1, true) then
        getUser = UserProxy.getUserByMail
    else
        getUser = UserProxy.getUserByLoginName
    end
    local user = getUser(loginname)
    if not user then
        res.status(403)
        return res.render('sign/signin', {the_error = '用户名或密码错误'})
    end
    local passhash = user.pass
    if tools.bcompare(pass, passhash) then
        if user.active ~= 1 then
            if not config.admins[user.loginname] then
                mail.sendActiveMail(user.email, tools.md5(user.email .. passhash .. config.session_secret), user.loginname)
                res.status(403)
                res.render('sign/signin', {the_error = '此帐号还没有被激活，激活链接已发送到 ' .. user.email .. ' 邮箱，请查收。'})
                return
            end
        end
        req.session.set(config.auth_cookie_name, user.id)
        local refer = req.session.get('loginReferer')
        if not refer or refer == "" then
            refer = '/'
        end
        req.session.set('loginReferer', nil)
        for i,v in ipairs(notJump) do
            if string.find(refer, notJump[i]) then
                refer = '/'
                break
            end
        end
        res.redirect(refer)
    else
        res.status(403)
        res.render('sign/signin', {the_error = '用户名或密码错误'})
    end
end

function exports.signout(req, res)
    req.session.set(config.auth_cookie_name, nil)
    res.redirect('/')
end

function exports.activeAccount(req, res)
    local key  = string.trim(req.query.key or '')
    local name = string.trim(req.query.name or '')
    if #key == 0 or #key > 64 or #name == 0 or #name > 64 then
        res.render('notify/notify', {the_error = '错误的激活链接'})
        return
    end
    local user = UserProxy.getUserByLoginName(name)
    if not user then
        return res.render('notify/notify', {the_error = '系统错误，帐号无法被激活。'})
    end
    local passhash = user.pass
    if tools.md5(user.email .. passhash .. config.session_secret) ~= key then
        return res.render('notify/notify', {the_error = '信息有误，帐号无法被激活。'})
    end
    if user.active == 1 then
        return res.render('notify/notify', {the_error = '帐号已经是激活状态。'})
    end
    user.active = 1
    user:save('active')
    res.render('notify/notify', {success = '帐号已被激活，请登录'})
end

function exports.showSearchPass(req, res)
    res.render('sign/search_pass')
end

function exports.updateSearchPass(req, res)
    local email = string.lower(string.trim(req.body.email or ''))
    if not tools.isEmail(email) then
        res.render('sign/search_pass', {the_error = '邮箱不合法', email = email})
        return
    end
    local retrieveTime = os.time()
    local user = UserProxy.getUserByMail(email)
    if not user then
        res.render('sign/search_pass', {the_error = '没有这个电子邮箱。', email = email})
        return
    end
    local retrieveKey = uuid()
    user.retrieve_key = retrieveKey
    user.retrieve_time = retrieveTime
    user:save('retrieve_key', 'retrieve_time')
    mail.sendResetPassMail(email, retrieveKey, user.loginname)
    res.render('notify/notify', {success = '我们已给您填写的电子邮箱发送了一封邮件，请在24小时内点击里面的链接来重置密码。'})
end

function exports.resetPass(req, res)
    local key  = string.trim(req.query.key or '')
    local name = string.trim(req.query.name or '')
    if #key == 0 or #key > 64 or #name == 0 or #name > 64 then
        res.render('notify/notify', {the_error = '错误的激活链接'})
        return
    end
    local user = UserProxy.getUserByNameAndKey(name, key)
    if not user then
        res.status(403)
        res.render('notify/notify', {the_error = '信息有误，密码无法重置。'})
        return
    end
    if not user.retrieve_time or os.time() - user.retrieve_time > 3600 * 24 then
        res.status(403)
        res.render('notify/notify', {the_error = '该链接已过期，请重新申请。'})
        return
    end
    res.render('sign/reset', {name = name, key = key})
end

function exports.updatePass(req, res)
    local body = req.body
    local psw   = string.trim(body.psw or '') 
    local repsw = string.trim(body.repsw or '') 
    local key   = string.trim(body.key or '') 
    local name  = string.trim(body.name or '')
    if #psw < 6 then
        res.render('sign/reset', {name = name, key = key, the_error = '密码至少需要6个字符。'})
        return
    end
    if psw ~= repsw then
        res.render('sign/reset', {name = name, key = key, the_error = '两次密码输入不一致。'})
        return
    end

    if #key == 0 or #key > 64 or #name == 0 or #name > 64 then
        res.render('notify/notify', {the_error = '错误的激活链接'})
        return
    end
    local user = UserProxy.getUserByNameAndKey(name, key)
    if not user then
        res.render('notify/notify', {the_error = '错误的激活链接'})
        return
    end
    local passhash = tools.bhash(psw)
    user.pass          = passhash
    user.retrieve_key  = nil
    user.retrieve_time = nil
    user.active        = 1
    user:save('pass', 'retrieve_key', 'retrieve_time', 'active')
    res.render('notify/notify', {success = '你的密码已重置。'})
end

return exports

