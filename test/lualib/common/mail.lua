local config = require "config"
local emaild = require "meiru.lib.emaild"

local SITE_ROOT_URL = 'https://' .. config.host

local exports = {}

function exports.sendActiveMail(who, token, name)
	local from    = config.mail_opts.user
	local to      = who
	local subject = config.name .. '社区帐号激活'
	local html    = '<p>您好：' .. name .. '</p>' ..
    '<p>我们收到您在' .. config.name .. '社区的注册信息，请点击下面的链接来激活帐户：</p>' ..
    '<a href  = "' .. SITE_ROOT_URL .. '/active_account?key=' .. token .. '&name=' .. name .. '">激活链接</a>' ..
    '<p>若您没有在' .. config.name .. '社区填写过注册信息，说明有人滥用了您的电子邮箱，请删除此邮件，我们对给您造成的打扰感到抱歉。</p>' ..
    '<p>' .. config.name .. '社区 谨上。</p>'

	local email = {
		from    = from,
		to      = to,
		subject = subject,
		content = html
	}
	-- log("exports.sendActiveMail====>>", '/active_account?key=' .. token .. '&name=' .. name)
	emaild.send_email(email, config.mail_opts)
end

function exports.sendResetPassMail(who, token, name)
	local from = config.mail_opts.user
	local to = who
	local subject = config.name .. '社区密码重置'
	local html = '<p>您好：' .. name .. '</p>' ..
    '<p>我们收到您在' .. config.name .. '社区重置密码的请求，请在24小时内单击下面的链接来重置密码：</p>' ..
    '<a href="' .. SITE_ROOT_URL .. '/reset_pass?key=' .. token .. '&name=' .. name .. '">重置密码链接</a>' ..
    '<p>若您没有在' .. config.name .. '社区填写过注册信息，说明有人滥用了您的电子邮箱，请删除此邮件，我们对给您造成的打扰感到抱歉。</p>' ..
    '<p>' .. config.name .. '社区 谨上。</p>'

    local email = {
		from    = from,
		to      = to,
		subject = subject,
		content = html
	}
	-- log("exports.sendResetPassMail====>>", '/reset_pass?key=' .. token .. '&name=' .. name)
	emaild.send_email(email, config.mail_opts)
end

return exports
