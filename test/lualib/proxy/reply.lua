
local skynet = require "skynet"
local Reply = require "model.reply"
local UserProxy = require "proxy.user"
local message = require "common.message"

local Proxy = {}

function Proxy.getReply(id)
    return Reply.findOne({id = id})
end

function Proxy.getReplyById(id)
    local reply = Reply.findOne({id = id})
    if not reply then
        return
    end
    local author = UserProxy.getUserById(reply.author_id)
    if not author then
        return
    end
    reply.author = author
    if reply.content_is_html then
        return reply
    end
    if not reply.linkedContent then
        reply.linkedContent = message.linkUsers(reply.content)
    end
    return reply
end

function Proxy.getRepliesByTopicId(id)
    local replies = Reply.find({topic_id = id, deleted = 0}, {sort = '+create_at'})
    for _,reply in ipairs(replies) do
        reply.author = UserProxy.getUserById(reply.author_id)
        if not reply.content_is_html then
            if not reply.linkedContent then
                reply.linkedContent = message.linkUsers(reply.content)
            end
        end
    end
    return replies
end

function Proxy.newAndSave(content, topicId, authorId, replyId)
    local data = {
        topic_id = topicId,
        content = content,
        author_id = authorId,
        reply_id = replyId
    }
    local reply = Reply.makeModel(data)
    reply:commit()
    return reply
end

function Proxy.getLastReplyByTopId(topicId)
    return Reply.find({topic_id = topicId, deleted = 0}, {sort = '-create_at', limit = 1})
end

function Proxy.getRepliesByAuthorId(authorId)
    return Reply.find({author_id = authorId})
end

function Proxy.getCountByAuthorId(authorId)
    return Reply.countDocuments({author_id = authorId})
end

return Proxy