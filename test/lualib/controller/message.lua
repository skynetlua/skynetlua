local config = require "config"
local MessageProxy = require "proxy.message"
local table = table
local string = string


local exports = {}

function exports.index(req, res)
    local user_id = req.session.user.id
    local has_read_msgs = MessageProxy.getReadMessagesByUserId(user_id)
    local has_read_messages = {}
    for _,msg in pairs(has_read_msgs) do
        MessageProxy.getMessageRelations(msg)
        if not msg.is_invalid then
            table.insert(has_read_messages, msg)
        end
    end

    local unread_msgs = MessageProxy.getUnreadMessageByUserId(user_id)
    local hasnot_read_messages = {}
    for _,msg in pairs(unread_msgs) do
        MessageProxy.getMessageRelations(msg)
        if not msg.is_invalid then
            table.insert(hasnot_read_messages, msg)
        end
    end
    MessageProxy.updateMessagesToRead(user_id, unread_msgs)
    return res.render('message/index', {has_read_messages = has_read_messages, hasnot_read_messages = hasnot_read_messages})
end


return exports

