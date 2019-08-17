local Model = require "meiru.db.model"

local TopicCollect = Model("TopicCollect")
function TopicCollect:ctor()
    -- log("TopicCollect:ctor id =",self.id)
end

return TopicCollect
