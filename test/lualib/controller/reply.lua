local config = require "config"
local message = require "common.message"
local TopicProxy = require "proxy.topic"
local UserProxy  = require "proxy.user"
local ReplyProxy = require "proxy.reply"
local fuckforbid = require "common.fuckforbid"

local table = table
local string = string

local exports = {}

function exports.add(req, res)
    local content = req.body.r_content
    local topic_id = tonumber(req.params.topic_id)
    local reply_id = tonumber(req.body.reply_id) or 0
    if type(content) ~= 'string' or #content == 0 then
        return res.renderCode(422, '回复内容不能为空!')
    end
    local topic = TopicProxy.getTopic(topic_id)
    if topic.lock == 1 then
        return res.render403('此主题已锁定。')
    end
    content = fuckforbid.cenvert_valid(content)
    local author_id = req.session.user.id
    local reply = ReplyProxy.newAndSave(content, topic_id, author_id, reply_id)
    TopicProxy.updateLastReply(topic_id, reply.id)
    message.sendAtMessage(topic.author_id, author_id, topic_id, reply.id)

    local user = UserProxy.getUserById(author_id)
    user.score = user.score + 5
    user.reply_count = user.reply_count + 1
    user:save('score', 'reply_count')
    req.session.user = user
    if topic.author_id ~= author_id then
        message.sendReplyMessage(topic.author_id, author_id, topic_id, reply.id)
    end
    return res.redirect(string.format("/topic/%s#%s", topic_id, reply.id))
end

function exports.delete(req, res)
    local reply_id = tonumber(req.body.reply_id)
    local reply = ReplyProxy.getReplyById(reply_id)
    if not reply then
        res.status(422)
        return res.json({status = string.format('no reply %s exists', reply_id)})
    end
    if reply.author_id == req.session.user.id or req.session.user.is_admin then
        reply.deleted = 1
        reply:save('deleted')
        reply.author.score = reply.author.score-5
        reply.author.reply_count = reply.author.reply_count-1
        reply.author:save('score', 'reply_count')
        TopicProxy.reduceCount(reply.topic_id)
        res.json({status = 'success'})
    else
        res.json({status = 'failed'})
    end
    return true
end

function exports.showEdit(req, res)
    local reply_id = tonumber(req.params.reply_id)
    local reply = ReplyProxy.getReplyById(reply_id)
    if not reply then
        return res.render404('此回复不存在或已被删除。')
    end
    if req.session.user.id == reply.author_id or req.session.user.is_admin then
        return res.render('reply/edit', {
            reply_id = reply.id,
            content  = reply.content
        })
    else
        return res.renderCode(403, '对不起，你不能编辑此回复。')
    end
end

function exports.update(req, res)
    local reply_id = tonumber(req.params.reply_id)
    local content = req.body.t_content
    local reply = ReplyProxy.getReplyById(reply_id)
    if not reply then
        return res.render404('此回复不存在或已被删除。')
    end
    if reply.author_id == req.session.user.id or req.session.user.is_admin then
        if type(content) == 'string' and #content > 0 then
            content = fuckforbid.cenvert_valid(content)
            reply.content = content
            reply:save('content')
            return res.redirect(string.format('/topic/%s#%s', reply.topic_id, reply.id))
        else
            return res.renderCode(400, '回复的字数太少。')
        end
    else
        return res.renderCode(403, '对不起，你不能编辑此回复。')
    end
end

function exports.up(req, res)
    local replyId = tonumber(req.params.reply_id)
    local userId = req.session.user.id
    local reply = ReplyProxy.getReplyById(replyId)
    if reply.author_id == userId and not config.debug then
        return res.json({
            success = false,
            message = '呵呵，不能帮自己点赞。',
        })
    else
        local action
        reply.ups = reply.ups or {}
        local upIndex = table.indexof(reply.ups, userId)
        if not upIndex then
            table.insert(reply.ups, userId)
            action = 'up'
        else
            table.remove(reply.ups, upIndex)
            action = 'down'
        end
        reply:save('ups')
        res.json({
            success = true,
            action = action
        })
    end
end

return exports
