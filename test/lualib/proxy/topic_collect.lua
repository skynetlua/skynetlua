
local skynet = require "skynet"
local TopicCollect = require "model.topiccollect"


local Proxy = {}

function Proxy.getTopicCollect(userId, topicId)
    return TopicCollect.findOne({user_id = userId, topic_id = topicId})
end

function Proxy.getTopicCollectsByUserId(userId)
   return TopicCollect.find({user_id = userId}, {sort = '-create_at'})
end

function Proxy.newAndSave(userId, topicId)
    local data = {
        user_id = userId,
        topic_id = topicId
    }
    local topic_collect = TopicCollect.makeModel(data)
    topic_collect:commit()
    return topic_collect
end

function Proxy.remove(userId, topicId)
    return TopicCollect.delete({user_id = userId, topic_id = topicId})
end

return Proxy