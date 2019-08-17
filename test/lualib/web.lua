
local skynet = require "skynet"
local meiru  = require "meiru.meiru"
local config = require "config"
local router = require "router"

local auth  = require "component.auth"
local response  = require "component.response"
local renderfunc = require "common.renderfunc"

local assets_path = skynet.getenv("assets_path")
local views_path  = assets_path .."view"
local static_path = assets_path .."static"
local static_url = "/"

local app = meiru.create_app()

app.set("views_path", views_path)
app.set("static_url", static_url)
app.data("config", config)
app.data(renderfunc)

app.set("session_secret", config.session_secret)


if os.mode == 'dev' then
	app.open_footprint()
else
	app.set("host", "www.skynetlua.com")
end

app.use(meiru.static('/public', static_path))
app.use(meiru.static('/favicon.ico', static_path))

local rnode = router.node()
rnode:add(response.render)
rnode:add(auth.authUser)
rnode:add(auth.blockUser)
app.use(rnode)



app.run()

return app

