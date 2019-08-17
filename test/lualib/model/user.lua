local Model = require "meiru.db.model"

local User = Model("User")
function User:ctor()
	-- log("User:ctor loginname =",self.loginname)
end

function User:getGravatar(email)
    if email then
        -- return User.makeGravatar(email)
    end
    return self.avatar 
end


return User

