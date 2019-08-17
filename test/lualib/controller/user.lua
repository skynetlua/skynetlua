local config = require "config"
local tools  = require "common.tools"
local uuid   = require "meiru.lib.uuid"
local TopicProxy = require "proxy.topic"
local UserProxy  = require "proxy.user"
local ReplyProxy  = require "proxy.reply"
local TopicCollectProxy = require "proxy.topic_collect"
local fuckforbid = require "common.fuckforbid"

local TopicModel = require "model.topic"
local ReplyModel = require "model.reply"

local string = string


local exports = {}

function exports.index(req, res)
    local user_name = req.params.name
    if type(user_name) ~= "string" or user_name == "" then
        return res.render404('这个用户不存在。')
    end
    local user = UserProxy.getUserByLoginName(user_name)
    if not user then
        return res.render404('这个用户不存在。')
    end

    local query = {author_id = user.id}
    local opt = {limit = 5, sort = '-create_at'}
    local recent_topics = TopicProxy.getTopicsByQuery(query, opt)

    local replies = ReplyProxy.getRepliesByAuthorId(user.id, {limit = 12, sort = '-create_at'})
    local topic_ids = {}
    for i,reply in ipairs(replies) do
        table.insert(topic_ids, reply.topic_id)
    end
    local query = {id = {['$in'] = topic_ids}}
    local opt = {}
    local recent_replies = TopicProxy.getTopicsByQuery(query, opt)

    --  如果用户没有激活，那么管理员可以帮忙激活
    local token = '';
    if user.active == 0 and req.session.user and req.session.user.is_admin then
        token = tools.md5(user.email .. user.pass .. config.session_secret)
    end
    return res.render('user/index', {
        user = user,
        recent_topics = recent_topics,
        recent_replies = recent_replies,
        token = token,
        pageTitle = string.format('@%s 的个人主页', user.loginname),
    })
end

function exports.showSetting(req, res)
    local user = UserProxy.getUserById(req.session.user.id)
    if req.query.save == 'success' then
        user.success = '保存成功。'
    end
    -- user.error = nil
    return res.render('user/setting', user)
end

function exports.setting(req, res)
    local function showMessage(msg, data, isSuccess)
        data = data or req.body
        local data2 = {
            loginname   = data.loginname,
            email       = data.email,
            url         = data.url,
            location    = data.location,
            signature   = data.signature,
            weibo       = data.weibo,
            accessToken = data.accessToken,
        }
        if isSuccess then
            data2.success = msg
        else
            data2.the_error = msg
        end
        res.render('user/setting', data2)
    end

    local action = req.body.action
    if action == 'change_setting' then
        local url       = string.trim(req.body.url)
        local location  = string.trim(req.body.location)
        -- local weibo     = string.trim(req.body.weibo)
        local signature = string.trim(req.body.signature)
        -- location = fuckforbid.cenvert_valid(location)
        -- weibo = fuckforbid.cenvert_valid(weibo)
        signature = fuckforbid.cenvert_valid(signature)

        local user = UserProxy.getUserById(req.session.user.id)
        user.url       = url
        user.location  = location
        user.signature = signature
        -- user.weibo     = weibo
        user:save('url', 'location', 'signature')
        req.session.user = user
        return res.redirect('/setting?save=success')

    elseif action == 'change_password' then
        local old_pass = string.trim(req.body.old_pass or '')
        local new_pass = string.trim(req.body.new_pass or '')
        if #old_pass == 0 or #new_pass == 0 then
            return showMessage('旧密码或新密码不得为空')
        end

        local user = UserProxy.getUserById(req.session.user.id)
        local ret = tools.bcompare(old_pass, user.pass)
        if not ret then
            return showMessage('当前密码不正确。', user)
        end
        user.pass = tools.bhash(new_pass)
        user:save('pass')
        return showMessage('密码已被修改。', user, true)
    end
end

function exports.toggleStar(req, res)
    local user_id = req.body.user_id
    local user = UserProxy.getUserById(user_id)
    if not user then
        return res.json({status = 'failed'})
    end
    user.is_star = user.is_star == 0 and 1 or 0
    user:save('is_star')
    res.json({status = 'success'})
end

function exports.listStars(req, res)
    local stars = UserProxy.getUsersByQuery({is_star = 1})
    return res.render('user/stars', {stars = stars})
end

function exports.top100(req, res)
    local opt = {limit = 100, sort = '-score'}
    local tops = UserProxy.getUsersByQuery({is_block = 0}, opt)
    return res.render('user/top100', {users = tops, pageTitle = 'top100'})
end

function exports.listCollectedTopics(req, res)
    local name = req.params.name
    local page = tonumber(req.query.page) or 1
    local limit = config.list_topic_count
    local user = UserProxy.getUserByLoginName(name)
    if not user then
        return res.render404('这个用户不存在。')
    end
    local pages = math.ceil(user.collect_topic_count/limit)
    local opt = {skip = (page - 1) * limit, limit = limit}
    local docs = TopicCollectProxy.getTopicCollectsByUserId(user.id, opt)
    local ids = {}
    for i,doc in ipairs(docs) do
        table.insert(ids, doc.topic_id)
    end
    local query = {id = {['$in'] = ids}}
    local topics = TopicProxy.getTopicsByQuery(query)
    return res.render('user/collect_topics', {topics = topics,user = user,current_page = page,pages = pages,})
end

function exports.listTopics(req, res)
    local user_name = req.params.name
    local page = tonumber(req.query.page) or 1
    local limit = config.list_topic_count
    local user = UserProxy.getUserByLoginName(user_name)
    if not user then
        return res.render404('这个用户不存在。')
    end
    local query = {author_id = user.id}
    local opt = {skip = (page - 1) * limit, limit = limit, sort = '-create_at'}
    local topics = TopicProxy.getTopicsByQuery(query, opt)
    local all_topics_count = TopicProxy.getCountByQuery(query)
    local pages = math.ceil(all_topics_count / limit)
    return res.render('user/topics', {topics = topics,user = user,current_page = page,pages = pages,})
end

function exports.listReplies(req, res)
    local user_name = req.params.name
    local page = tonumber(req.query.page) or 1
    local limit = 50
    local user = UserProxy.getUserByLoginName(user_name)
    if not user then
        return res.render404('这个用户不存在。')
    end
    local opt = {skip = (page - 1) * limit, limit = limit, sort = '-create_at'}
    local replies = ReplyProxy.getRepliesByAuthorId(user.id, opt)
    local topic_ids = {}
    for _,reply in ipairs(replies) do
        topic_ids[reply.topic_id] = reply.topic_id
    end
    local tmps = {}
    for _,topic_id in pairs(topic_ids) do
        table.insert(tmps, topic_id)
    end
    topic_ids = tmps
    local query = {id = {['$in'] = topic_ids}}
    local topics = TopicProxy.getTopicsByQuery(query)
    local count = ReplyProxy.getCountByAuthorId(user.id)
    local pages = math.ceil(count / limit)
    return res.render('user/replies', {user = user,topics = topics,current_page = page,pages = pages})
end

function exports.block(req, res)
    local loginname = req.params.name
    local action = req.body.action
    local user = UserProxy.getUserByLoginName(loginname)
    if not user then
        return res.json({status = 'failed', errmsg = 'user is not exists'})
    end
    if action == 'set_block' then
        user.is_block = 1
        user:save('is_block')
        return res.json({status = 'success'})
    elseif action == 'cancel_block' then
        user.is_block = 0
        user:save('is_block')
        return res.json({status = 'success'})
    end
end

function exports.deleteAll(req, res)
    local loginname = req.params.name
    local user = UserProxy.getUserByLoginName(loginname)
    if not user then
        return res.json({status = 'failed', errmsg = 'user is not exists'})
    end
    TopicModel.updateMany({author_id = user.id}, {deleted = 1})
    ReplyModel.updateMany({author_id = user.id}, {deleted = 1})

    return res.json({status = 'success'})
end

function exports.refreshToken(req, res)
    local user_id = req.session.user.id
    local user = UserProxy.getUserById(user_id)
    user.accessToken = uuid()
    user:save('accessToken')
    res.json({status = 'success', accessToken = user.accessToken})
end

return exports
