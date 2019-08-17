local skynet = require "skynet.manager"
local filed = require "meiru.lib.filed"

skynet.start(function()
    filed.init()
    local fuckforbid = skynet.uniqueservice("common/fuckforbid", ".fuckforbid")
    skynet.name(".fuckforbid", fuckforbid)

    if skynet.getenv("auto_mysql") then
        local mysqlcheckd = skynet.newservice("meiru/mysqlcheckd")
        skynet.call(mysqlcheckd, "lua", "start")
    end

    local http_port     = skynet.getenv("http_port")
    local service_http  = skynet.getenv("service_http")
    local service_ws    = skynet.getenv("service_ws")

    local https_port     = skynet.getenv("https_port")
    local service_https = skynet.getenv("service_https")
    local service_wss   = skynet.getenv("service_wss")
    local service_num   = skynet.getenv("service_num")
    if service_http or service_ws then
        local httpd = skynet.newservice("meiru/serverd")
        local param = {
            port = http_port,
            services = {},
            instance = service_num or 4,
        }
        if service_http then
            param.services['http'] = service_http
        end
        if service_ws then
            param.services['ws'] = service_ws
        end
        skynet.call(httpd, "lua", "start", param)
    end

    if service_https or service_wss then
        local httpsd = skynet.newservice("meiru/serverd")
        local param = {
            port = https_port,
            services = {},
            instance = service_num or 4,
        }
        if service_https then
            param.services['https'] = service_https
        end
        if service_wss then
            param.services['wss'] = service_wss
        end
        skynet.call(httpsd, "lua", "start", param)
    end

    -- local httpsd = skynet.newservice("meiru/serverd")
    -- skynet.call(httpsd, "lua", "start", {
    --     port = skynet.getenv("httpsport"),
    --     services = {
    --         ['https'] = "web", 
    --         ['wss'] = "ws"
    --     },
    --     instance = 4,
    -- })

    -- local httpd = skynet.newservice("meiru/serverd")
    -- skynet.call(httpd, "lua", "start", {
    --     port = skynet.getenv("httpport"),
    --     services = {
    --         ['http'] = "web", 
    --         ['ws'] = "ws"
    --     },
    --     instance = 4,
    -- })

end)



