local config = require "config"
local system = require "api.system"
local auth  = require "component.auth"
local limit = require "component.limit"
local comgithub = require "component.github"
local meiru  = require "meiru.meiru"

local router = meiru.router()

router.get('/api/system/:what', system.index)

return router