local config = require "config"
local site   = require "controller.site"
local user   = require "controller.user"
local sign   = require "controller.sign"
local static = require "controller.static"
local topic  = require "controller.topic"
local reply  = require "controller.reply"
local system = require "controller.system"
local github = require "controller.github"
local search = require "controller.search"
local message = require "controller.message"

local auth  = require "component.auth"
local limit = require "component.limit"
local comgithub = require "component.github"

local meiru  = require "meiru.meiru"
local router = meiru.router()

router.get('/', site.index)

--static
router.get('/about', static.about)
router.get('/handbook', static.handbook)
router.get('/admin', static.admin)
router.get('/project', static.project)
router.get('/robots.txt', static.robots)

--search
router.get('/search', search.index)

--topic
router.get('/topic/create', auth.userRequired, topic.create)
router.post('/topic/create', auth.userRequired, limit.peruserperday('create_topic', config.create_post_per_day, {showJson = false}), topic.put)

router.get('/topic/:tid', topic.index)
router.get('/topic/:tid/edit', auth.userRequired, topic.showEdit)
router.post('/topic/:tid/edit', auth.userRequired, topic.update)

router.post('/topic/:tid/top', auth.adminRequired, topic.top)
router.post('/topic/:tid/good', auth.adminRequired, topic.good)
router.post('/topic/:tid/lock', auth.adminRequired, topic.lock)
router.post('/topic/:tid/delete', auth.userRequired, topic.delete)
router.post('/topic/collect', auth.userRequired, topic.collect)
router.post('/topic/de_collect', auth.userRequired, topic.de_collect)
router.post('/upload', auth.userRequired, topic.upload)

--reply
router.post('/:topic_id/reply', auth.userRequired, limit.peruserperday('create_reply', config.create_reply_per_day, {showJson = false}), reply.add)
router.get('/reply/:reply_id/edit', auth.userRequired, reply.showEdit)
router.post('/reply/:reply_id/edit', auth.userRequired, reply.update)
router.post('/reply/:reply_id/delete', auth.userRequired, reply.delete)
router.post('/reply/:reply_id/up', auth.userRequired, reply.up)

router.post('/user/refresh_token', auth.userRequired, user.refreshToken)

--message
router.get('/my/messages', auth.userRequired, message.index)

--user
router.get('/user/:name', user.index)

router.get('/stars', user.listStars)
router.get('/users/top100', user.top100)
router.get('/user/:name/collections', user.listCollectedTopics)
router.get('/user/:name/topics', user.listTopics)
router.get('/user/:name/replies', user.listReplies)
router.post('/user/set_star', auth.adminRequired, user.toggleStar)
router.post('/user/cancel_star', auth.adminRequired, user.toggleStar)
router.post('/user/:name/block', auth.adminRequired, user.block)
router.post('/user/:name/delete_all', auth.adminRequired, user.deleteAll)

--sign
if config.allow_sign_up then
	router.get('/signup', sign.showSignup)
 	router.post('/signup', sign.signup)
else
	router.get('/signup', function(req, res)
    	return res.redirect('/auth/github')
 	end)
end

router.get('/signin', sign.showLogin)
router.post('/signin', sign.login)
router.post('/signout', sign.signout)
router.get('/active_account', sign.activeAccount)

router.get('/auth/github', comgithub.github, github.auth)
router.get('/auth/github/callback', comgithub.auth ,github.callback)
router.get('/auth/github/new', github.new);
router.post('/auth/github/create', limit.peripperday('create_user_per_ip', config.create_user_per_ip, {showJson = false}), github.create)

router.get('/search_pass', sign.showSearchPass)
router.post('/search_pass', sign.updateSearchPass)
router.get('/reset_pass', sign.resetPass)
router.post('/reset_pass', sign.updatePass)

router.get('/setting', auth.userRequired, user.showSetting)
router.post('/setting', auth.userRequired, user.setting)

local system = require "controller.system"
router.get('/system/index', system.index)

-- if not config.debug then
-- 	router.get('/:name', function(req, res)
-- 		res.redirect('/user/'.. req.params.name)
-- 	end)
-- end


return router