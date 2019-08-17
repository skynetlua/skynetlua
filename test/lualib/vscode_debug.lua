local projects_path = package.path:match("(.*)/([^/]+)$")
package.path = package.path ..";"..projects_path.."/test/lualib/?.lua;"
package.path = package.path ..";"..projects_path.."/meiru/lualib/?.lua;"

os.mode = 'dev'
local extension = require "meiru.extension"
local meiru     = require "meiru.meiru"
local renderfunc = require "common.renderfunc"

---------------------------------------
--router
---------------------------------------
local router = meiru.router()

router.get('tutorial/index', function(req, res)
    -- local data = {
    --     topic = {
    --         title = "hello ejs.lua"
    --     },
    --     topics = {
    --         {
    --             title = "topic1"
    --         },{
    --             title = "topic2"
    --         }
    --     }
    -- }
    -- function data.helloworld(...)
    --     if select("#", ...) > 0 then
    --         return "come from helloworld function"..table.concat(... , ", ")
    --     else
    --         return "come from helloworld function"
    --     end
    -- end
    res.set_layout("")
    return res.render('tutorial/index', {})
end)

---------------------------------------
--app
---------------------------------------
local app = meiru.create_app()

local config = {
    name = 'meiru', 
    description = 'meiru web framework', 
    keywords = 'meiru skynet lua skynetlua'
}

local static_url = "/"
local static_path = projects_path.."/test/assets/static"
local views_path = projects_path.."/test/assets/view"

app.data(renderfunc)
app.data("config", config)
app.set("static_url", static_url)
app.set("views_path", views_path)

-- app.set("host", "127.0.0.1")
app.use(meiru.static('/public', static_path))
app.use(router.node())
app.run()

-- local tree = app.treeprint()
-- log("treeprint\n", tree)

---------------------------------------
--dispatch
---------------------------------------
local req = {
    protocol = 'http',
    method   = "get",
    url      = "/tutorial/index",
    header  = {},
    body     = "",
}

req.header = {
    ['connection'] = "keep-alive",
    ['cookie'] = "mrsid=s%3Apw93qo6lxjs15.598e194705b662f2e985fe8e18328ac6",
    ['sec-fetch-mode'] = "no-cors",
    ['host'] = "127.0.0.1:8080",
    ['accept-encoding'] = "gzip, deflate, br",
    ['sec-fetch-site'] = "same-origin",
    ['referer'] = "http://127.0.0.1:8080/",
    ['pragma'] = "no-cache",
    ['accept-language'] = "zh-CN,zh;q=0.9",
    ['cache-control'] = "no-cache",
    ['accept'] = "image/webp,image/apng,image/*,*/*;q=0.8",
    ['user-agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36",
}

local res = {
    response = function(code, bodyfunc, header)
        log("response", code, header)
    end,
}

app.dispatch(req, res)

-- local memory_info = dump_memory()
-- log("memory_info\n", memory_info)

-- local foot = app.footprint()
-- log("footprint\n", foot)

-- local chunk = app.chunkprint()
-- log("chunkprint\n", chunk)
