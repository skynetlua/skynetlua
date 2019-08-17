local config = require "config"
local httpc  = require "http.httpc"
local Coder  = require "meiru.role.coder"
Coder = Coder("json")

local exports = {}

function exports.github(req, res)
	if config.GITHUB_OAUTH.clientID == 'your GITHUB_CLIENT_ID' then
		return res.send('call the admin to set github oauth.')
	end
end

function exports.auth(req, res)
	if not req.query or not req.query.code then
		log("github auth error req.query =", req.query)
		return false
	end
	local path = string.format("/login/oauth/access_token?client_id=%s&client_secret=%s&code=%s&scope=skynetlua",
	 		config.GITHUB_OAUTH.clientID,
	 		config.GITHUB_OAUTH.clientSecret,
	 		req.query.code)
	local host = "https://github.com"
	local recvheader = {}
	local form = {}
	local status, body = httpc.post(host, path, form, recvheader)
	if status ~= 200 then
		log("github auth failed. path =", path)
		return false
	end
	local tmp = body:urldecode()
	local items = tmp:split("&")
	local profile = {}
	for _,item in ipairs(items) do
		tmp = item:split("=")
		profile[tmp[1]] = tmp[2] or ""
	end
	if not profile.access_token then
		log("github auth failed. profile =", profile)
		return false
	end

	local path = "/user?access_token="..profile.access_token
	local host = "https://api.github.com"
	local reqheader = {
        ['User-Agent'] = "meiru framework;skynetlua"
    }
	local recvheader = {}
	local status, body = httpc.get(host, path, recvheader, reqheader)
	if status ~= 200 then
		log("github user failed. path =", path)
		return false
	end
	log("github body =", body)

	local tmp = Coder.decode(body)
	tmp.access_token = profile.access_token
	
	req.session.profile = {
		id = tmp.id,
		login = tmp.login,
		name = tmp.name,
		avatar_url = tmp.avatar_url,
		html_url = tmp.html_url,
		blog = tmp.blog,
		email = tmp.email,
		location = tmp.location,
		access_token = tmp.access_token,
	}
end

-- {
-- 	"login":"skynetlua",
-- 	"id":52807054,
-- 	"node_id":"MDQ6VXNlcjUyODA3MDU0",
-- 	"avatar_url":"https://avatars3.githubusercontent.com/u/52807054?v=4",
-- 	"gravatar_id":"",
-- 	"url":"https://api.github.com/users/skynetlua",
-- 	"html_url":"https://github.com/skynetlua",
-- 	"followers_url":"https://api.github.com/users/skynetlua/followers",
-- 	"following_url":"https://api.github.com/users/skynetlua/following{/other_user}",
-- 	"gists_url":"https://api.github.com/users/skynetlua/gists{/gist_id}",
-- 	"starred_url":"https://api.github.com/users/skynetlua/starred{/owner}{/repo}",
-- 	"subscriptions_url":"https://api.github.com/users/skynetlua/subscriptions",
-- 	"organizations_url":"https://api.github.com/users/skynetlua/orgs",
-- 	"repos_url":"https://api.github.com/users/skynetlua/repos",
-- 	"events_url":"https://api.github.com/users/skynetlua/events{/privacy}",
-- 	"received_events_url":"https://api.github.com/users/skynetlua/received_events",
-- 	"type":"User",
-- 	"site_admin":false,
-- 	"name":"linyouhappy",
-- 	"company":null,
-- 	"blog":"www.skynetlua.com",
-- 	"location":"guangzhou",
-- 	"email":"skynetlua@foxmail.com",
-- 	"hireable":null,
-- 	"bio":"https://github.com/linyouhappy",
-- 	"public_repos":10,
-- 	"public_gists":0,
-- 	"followers":2,
-- 	"following":0,
-- 	"created_at":"2019-07-12T01:45:11Z",
-- 	"updated_at":"2019-08-15T11:50:34Z"
-- }


return exports