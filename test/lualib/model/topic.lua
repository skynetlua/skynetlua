local Model = require "meiru.db.model"

local Topic = Model("Topic")
function Topic:ctor()
    -- log("Topic:ctor id =",self.id)
    -- log("self =", self)
end

return Topic
