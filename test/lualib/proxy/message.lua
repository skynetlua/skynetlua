
local skynet = require "skynet"
local Message = require "model.message"
local TopicProxy = require "proxy.topic"
local UserProxy = require "proxy.user"
local ReplyProxy = require "proxy.reply"


local Proxy = {}

function Proxy.getMessagesCount(id)
    return Message.countDocuments({master_id = id, has_read = 0})
end

function Proxy.getMessageRelations(message)
    if message.type == 'reply' or message.type == 'reply2' or message.type == 'at' then
        message.author = UserProxy.getUserById(message.author_id)
        message.topic = TopicProxy.getTopicById(message.topic_id)
        message.reply = ReplyProxy.getReplyById(message.reply_id)
        if not message.author or not message.topic then
            message.is_invalid = true
        end
    else
        message.is_invalid = true
    end
end

function Proxy.getMessageById(id)
    id = tonumber(id)
    if not id then
        return
    end
    local message = Message.findOne({id = id})
    getMessageRelations(message)
end

function Proxy.getReadMessagesByUserId(userId)
    return  Message.find({master_id = userId, has_read = 1},{sort = '-create_at', limit = 20})
end

function Proxy.getUnreadMessageByUserId(userId)
    return  Message.find({master_id = userId, has_read = 0},{sort = '-create_at'})
end

function Proxy.updateMessagesToRead(userId, messages)
    if #messages == 0 then
        return
    end
    local ids = {}
    for _,m in ipairs(messages) do
        table.insert(ids, m.id)
    end
    local query = {master_id = userId, id = {['$in'] = ids}}
    Message.updateMany(query, {has_read = 1})
end

function Proxy.updateOneMessageToRead(msg_id, messages)
    if not msg_id then
        return
    end
    local query = {id = msg_id}
    Message.updateMany(query, {has_read = 1})
end

function Proxy.newAndSave(msg_type, master_id, author_id, topic_id, reply_id)
    local data = {
        type      = msg_type,
        master_id = master_id,
        author_id = author_id,
        topic_id  = topic_id,
        reply_id  = reply_id,
    }
    local message = Message.makeModel(data)
    message:commit()
    return message
end


return Proxy