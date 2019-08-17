local skynet = require "skynet"
local BaseModel = require "model.base_model"

local Cache = BaseModel("Cache")
function Cache:ctor()
    -- skynet.error("Cache:ctor id =",self.id)
end

return Cache
