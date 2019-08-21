local config = require "config"

local exports = {}

function exports.about(req, res)
    return res.render('static/about', {
        pageTitle = '关于我们'
    })
end

function exports.admin(req, res)
    return res.render('static/admin', {
        pageTitle = '管理后台'
    })
end

function exports.handbook(req, res)
    return res.render('static/handbook', {
        pageTitle = '开发手册'
    })
end

function exports.project(req, res)
    return res.render('static/project', {
        pageTitle = '开源项目'
    })
end

function exports.robots(req, res)
    res.type('text/plain')
    res.send("# Welcome to skynetlua")
-- res.send(
-- [[# See http://www.robotstxt.org/robotstxt.html for documentation on how to use the robots.txt file
-- #
-- # To ban all spiders from the entire site uncomment the next two lines:
-- # User-Agent: *
-- # Disallow: /
-- ]])
end

-- function exports.api(req, res)
--     return res.render('static/api')
-- end


return exports

