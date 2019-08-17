local UserProxy = require "proxy.user"
local config = require "config"
local table = table
local string = string

local exports = {}

function exports.auth(req, res)
    local url = "https://github.com/login/oauth/authorize?scope=skynetlua&client_id="..config.GITHUB_OAUTH.clientID
    return res.redirect(url)
end

local function is_empty_string(val)
    if type(val) ~= 'string' or #val == 0 then
        return true
    end
end

local function assign(user, profile)
    assert(user.githubId == profile.id)
    user.githubUsername = profile.login
    user.githubAccessToken = profile.access_token
    if is_empty_string(user.location) then
        user.location = profile.location
    end
    if is_empty_string(user.avatar) then
        user.avatar = profile.avatar_url
    end
    if is_empty_string(user.url) then
        if is_empty_string(profile.blog) then
            user.url = profile.html_url
        else
            user.url = profile.blog
        end
    end
    if is_empty_string(user.email) then
        if is_empty_string(profile.email) then
            if type(profile.email) == "table" then
                user.email = profile.email[1]
            end
        else
            user.email = profile.email
        end
    end
end

function exports.callback(req, res)
    local profile = req.session.profile
    local user = UserProxy.findOne({githubId = profile.id})
    if user then
        assign(user, profile)
        user:commit()
        req.session.set(config.auth_cookie_name, user.id)
        return res.redirect('/')
    else
        req.session.set("github", profile)
        return res.redirect('/auth/github/new')
    end
end

function exports.new(req, res)
    return res.render('sign/new_oauth', {actionPath = '/auth/github/create'})
end

function exports.create(req, res)
    local profile = req.session.get("github")
    if not profile then
        return res.redirect('/signin')
    end
    req.session.set("github", nil)
    local isnew = req.body.isnew
    if isnew then
        local loginname = profile.login
        local user = UserProxy.findOne({loginname = loginname})
        if user then
            return res.status(403).render('sign/signin', {the_error = "账号名'"..loginname.."'已被注册"})
        end
        local data = {
            githubId = profile.id,
            loginname = loginname,
        }
        assign(data, profile)
        if is_empty_string(data.email) then
            data.email = tostring(profile.id)
        end
        user = UserProxy.newAndSave(data)
        req.session.set(config.auth_cookie_name, user.id)
        return res.redirect('/')
    else
        local loginname = string.trim(req.body.name:lower())
        local password = string.trim(req.body.pass or '')
        local user = UserProxy.findOne({loginname = loginname})
        if not user then
            return res.status(403).render('sign/signin', {the_error = '账号名或密码错误。'})
        end
        local ret = tools.bcompare(password, user.pass)
        if not ret then
            return res.status(403).render('sign/signin', {the_error = '账号名或密码错误。'})
        end
        user.githubId = profile.id
        assign(user, profile)
        user:commit()

        req.session.set(config.auth_cookie_name, user.id)
        return res.redirect('/')
    end
end

return exports