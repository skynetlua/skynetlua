local Model = require "meiru.db.model"

local Session = Model("Session")
function Session:ctor()
	-- log("Session:ctor id =",self.id)
end

return Session
