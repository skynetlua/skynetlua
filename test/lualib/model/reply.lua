local Model = require "meiru.db.model"

local Reply = Model("Reply")
function Reply:ctor()
    -- log("Reply:ctor id =",self.id)
end

return Reply
