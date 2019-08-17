local config = require "config"
local TopicProxy = require "proxy.topic"
local UserProxy  = require "proxy.user"
local renderfunc = require "common.renderfunc"
local cached = require "meiru.db.cached"

local exports = {}

local kMCacheInterval = 60*1

function exports.index(req, res)
    local page = tonumber(req.query.page or 1) 
    page = page > 0 and page or 1
    local tab = req.query.tab
    local tab_info = {'all', '全部'}
    for _,v in pairs(config.tabs) do
        if v[1] == tab then
            tab_info = v
        end
    end
    tab = tab_info[1]
    local tabName = tab_info[2]

    local limit = config.list_topic_count or 20
    local cache_key = 'topics'..tab..page
    local topics_cache = cached.get(cache_key)
    if not topics_cache then
        local query = {
            tab =  (tab and tab ~= 'all') and tab or nil,
            create_at = {['$gte'] = os.time()-3600*24*365}
        }
        local options = {skip = (page - 1) * limit, limit = limit, sort = '-top -last_reply_at'}
        local topics = TopicProxy.getTopicsByQuery(query, options)

        local all_topics_count = TopicProxy.getCountByQuery(query) or 0
        local page_num = math.ceil(all_topics_count / limit)

        topics_cache = {
            topics = topics,
            page_num = page_num,
        }
        cached.set(cache_key, topics_cache, kMCacheInterval)
    end

    local cache_key = 'top_users_no_reply_topics'
    local side_cache = cached.get(cache_key)
    if not side_cache then
        local top_users = UserProxy.getUsersByQuery({is_block = 0},{limit = 10, sort = '-score'})
        local no_reply_topics = TopicProxy.getTopicsByQuery({reply_count = 0},{limit = 5, sort = '-create_at'})
        side_cache = {
            top_users = top_users,
            no_reply_topics = no_reply_topics,
        }
        cached.set(cache_key, side_cache, 60*9)
    end

    res.render('index', {
        topics           = topics_cache.topics,
        current_page     = page,
        -- list_topic_count = limit,
        page_num         = topics_cache.page_num,
        tops             = side_cache.top_users,
        no_reply_topics  = side_cache.no_reply_topics,
        tabs             = config.tabs,
        tab              = tab,
        pageTitle        = tabName and (tabName .. '版块'),
      })
    return true
end


return exports

