
local skynet = require "skynet"
local Topic = require "model.topic"
local UserProxy = require "proxy.user"
local ReplyProxy = require "proxy.reply"
-- local at = require "common.at"
local message = require "common.message"

local Proxy = {}


function Proxy.getTopicById(id)
    id = tonumber(id)
    local topic = Topic.findOne({id = id})
    return topic
end

function Proxy.getCountByQuery(query, option)
    return Topic.countDocuments(query, option)
end

function Proxy.getTopicsByQuery(query, option)
    query.deleted = 0
    local topics = Topic.find(query, option)
    local retval = {}
    for _,topic in ipairs(topics) do
        topic.author = UserProxy.getUserById(topic.author_id)
        if topic.author and topic.last_reply then
            topic.reply = ReplyProxy.getReplyById(topic.last_reply)
        end
        table.insert(retval, topic)
    end
    return retval
end

function Proxy.getFullTopic(id)
    id = tonumber(id)
    local topic = Topic.findOne({id = id, deleted = 0})
    if not topic then
        return
    end
    local author = UserProxy.getUserById(topic.author_id)
    if not author then
        return
    end
    if not topic.linkedContent then
        topic.linkedContent = message.linkUsers(topic.content)
    end
    local replies = ReplyProxy.getRepliesByTopicId(topic.id)
    return topic, author, replies
end

function Proxy.updateLastReply(topicId, replyId)
    local topic = Topic.findOne({id = topicId})
    if not topic then
        return
    end
    topic.last_reply    = replyId
    topic.last_reply_at = os.time()
    topic.reply_count = topic.reply_count+1
    topic:save('last_reply', 'last_reply_at', 'reply_count')
end

function Proxy.getTopic(topicId)
    return Topic.findOne({id = topicId})
end

function Proxy.reduceCount(topicId)
    local topic = Topic.findOne({id = topicId})
    if not topic then
        return
    end
    topic.reply_count = topic.reply_count - 1
    local reply = ReplyProxy.getLastReplyByTopId(topicId)
    if reply and #reply>0 then
        topic.last_reply = reply[1].id
    else
        topic.last_reply = 0
    end
    topic:save('last_reply', 'reply_count')
end

function Proxy.newAndSave(title, content, tab, authorId)
    local data = {
        title = title,
        content = content,
        tab = tab,
        author_id = authorId,
    }
    local topic = Topic.makeModel(data)
    topic:commit()
    return topic
end


return Proxy