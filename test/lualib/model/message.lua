local Model = require "meiru.db.model"

local Message = Model("Message")
function Message:ctor()
    -- log("Message:ctor id =",self.id)
end

return Message
