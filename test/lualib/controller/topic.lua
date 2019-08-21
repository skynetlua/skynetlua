local config = require "config"
local cached = require "meiru.db.cached"
local TopicProxy = require "proxy.topic"
local UserProxy  = require "proxy.user"
local ReplyProxy = require "proxy.reply"
local TopicCollectProxy = require "proxy.topic_collect"
local fuckforbid = require "common.fuckforbid"
local message = require "common.message"

local exports = {}

function exports.index(req, res)
    local function isUped(user, reply)
        if type(reply.ups) ~= 'table' or #reply.ups == 0 then
            return false
        end
        return table.indexof(reply.ups, user.id)
    end

    local topic_id = tonumber(req.params.tid)
    if not topic_id or topic_id <= 0 then
        return res.render404('此话题不存在或已被删除。')
    end
    
    local topic, author, replies = TopicProxy.getFullTopic(topic_id)
    if not topic then
        return res.render404('此话题不存在或已被删除。')
    end

    topic.visit_count = topic.visit_count+1
    topic:save('visit_count')
    topic.author  = author
    topic.replies = replies

    if replies then
        local allUpCount = {}
        for _,reply in ipairs(replies) do
            if reply.ups and #reply.ups > 0 then
                table.insert(allUpCount, #reply.ups)
            else
                table.insert(allUpCount, 0)
            end
        end
        table.sort(allUpCount)
        local threshold = allUpCount[2] or 0
        if threshold < 3 then
            threshold = 3
        end
        topic.reply_up_threshold = threshold
    end

    local query = {author_id = topic.author_id, id = {['$nin'] = {topic.id}}}
    local other_topics = TopicProxy.getTopicsByQuery(query, {limit = 5, sort = '-last_reply_at'})

    local no_reply_topics = cached.get('no_reply_topics')
    if not no_reply_topics then
        no_reply_topics = TopicProxy.getTopicsByQuery({reply_count = 0, tab = {['$nin'] = {'job', 'dev'}}},{limit = 5, sort = '-create_at'})
        cached.get('no_reply_topics', no_reply_topics, 1*60)
    end

    local is_collect
    if req.session.user then
        is_collect = TopicCollectProxy.getTopicCollect(req.session.user.id, topic_id) and true or false
    end

    return res.render('topic/index', {
        topic               = topic,
        author_other_topics = other_topics,
        no_reply_topics     = no_reply_topics,
        is_uped             = isUped,
        is_collect          = is_collect,
    })
end

function exports.create(req, res)
    return res.render('topic/edit', {tabs = config.tabs})
end

function exports.put(req, res)
    local title   = string.trim(req.body.title)
    local tab     = string.trim(req.body.tab)
    local content = req.body.t_content

    local allTabs = {}
    for _,_tab in pairs(config.tabs) do
        allTabs[_tab[1]] = true
    end

    local editError
    if title == '' then
        editError = '标题不能是空的。'
    elseif #title < 5 or #title > 100 then
        editError = '标题字数太多或太少。'
    elseif not tab or not allTabs[tab] then
        editError = '必须选择一个版块。'
    elseif content == '' then
        editError = '内容不可为空'
    end
    if editError then
        res.status(422)
        return res.render('topic/edit', {edit_error = editError,title = title,content = content,tabs = config.tabs})
    end
    title = fuckforbid.cenvert_valid(title)
    content = fuckforbid.cenvert_valid(content)
    local topic = TopicProxy.newAndSave(title, content, tab, req.session.user.id)
    local user = UserProxy.getUserById(req.session.user.id)
    user.score = user.score + 5
    user.topic_count = user.topic_count + 1
    user:save('score', 'topic_count')
    req.session.user = user
    message.sendMessageToMentionUsers(content, topic.id, req.session.user.id)
    return res.redirect('/topic/' .. topic.id)
end

function exports.showEdit(req, res)
    local topic_id = tonumber(req.params.tid)
    local topic = TopicProxy.getTopicById(topic_id)
    if not topic then
        return res.render404('此话题不存在或已被删除。')
    end
    if topic.author_id == req.session.user.id or req.session.user.is_admin then
        return res.render('topic/edit', {
            action   = 'edit',
            topic_id = topic.id,
            title    = topic.title,
            content  = topic.content,
            tab      = topic.tab,
            tabs     = config.tabs
        })
    else
        return res.send(403, '对不起，你不能编辑此话题。')
    end
end

function exports.update(req, res)
    local topic_id = tonumber(req.params.tid)
    local title    = req.body.title or ''
    local tab      = req.body.tab or ''
    local content  = req.body.t_content
    local topic = TopicProxy.getTopicById(topic_id)
    if not topic then
        return res.render404('此话题不存在或已被删除。')
    end
    if topic.author_id == req.session.user.id or req.session.user.is_admin then
        title   = string.trim(title)
        tab     = string.trim(tab)
        content = content

        local editError
        if title == '' then
            editError = '标题不能是空的。'
        elseif #title < 5 or #title > 100 then
            editError = '标题字数太多或太少。'
        elseif tab == '' then
            editError = '必须选择一个版块。'
        end
        if editError then
            return res.render('topic/edit', {
                action     = 'edit',
                edit_error = editError,
                topic_id   = topic.id,
                content    = content,
                tabs       = config.tabs
            })
        end
        title = fuckforbid.cenvert_valid(title)
        content = fuckforbid.cenvert_valid(content)

        topic.title   = title
        topic.content = content
        topic.tab     = tab
        topic:save('title', 'content', 'tab')
        message.sendMessageToMentionUsers(content, topic.id, req.session.user.id)
        return res.redirect('/topic/' .. topic.id)
    else
        return res.send(403, '对不起，你不能编辑此话题。')
    end
end

function exports.delete(req, res)
    local topic_id = tonumber(req.params.tid)
    if not topic_id or topic_id <= 0 then
        res.status(404)
        return res.json({success = false, message = '此话题不存在或已被删除'})
    end
    local topic, author, replies = TopicProxy.getFullTopic(topic_id)
    if not req.session.user.is_admin and topic.author_id ~= req.session.user.id then
        res.status(403)
        return res.json({success = false, message = '无权限'})
    end
    if not topic then
        res.status(422)
        return res.json({success = false, message = '此话题不存在或已被删除。'})
    end
    author.score = author.score - 5
    author.topic_count = author.topic_count - 1
    author:save('score', 'topic_count')
    topic.deleted = 1
    topic:save('deleted')
    return res.json({success = true, message = '话题已被删除。'})
end

function exports.top(req, res)
    local topic_id = tonumber(req.params.tid)
    if not topic_id or topic_id <= 0 then
        return res.render404('此话题不存在或已被删除。')
    end
    local topic = TopicProxy.getTopic(topic_id)
    if not topic then
        return res.render404('此话题不存在或已被删除。')
    end
    topic.top = topic.top == 1 and 0 or 1
    topic:save('top')
    local msg = topic.top == 1 and '此话题已置顶。' or '此话题已取消置顶。'
    local referer = req.get('referer') or "/"
    return res.render('notify/notify', {success = msg, referer = referer})
end

function exports.good(req, res)
    local topic_id = tonumber(req.params.tid)
    if not topic_id or topic_id <= 0 then
        return res.render404('此话题不存在或已被删除。')
    end
    local topic = TopicProxy.getTopic(topic_id)
    if not topic then
        return res.render404('此话题不存在或已被删除。')
    end
    topic.good = topic.good == 1 and 0 or 1
    topic:save('good')
    local msg = topic.good == 1 and '此话题已加精。' or '此话题已取消加精。'
    local referer = req.get('referer')
    return res.render('notify/notify', {success = msg, referer = referer})
end

function exports.lock(req, res)
    local topic_id = tonumber(req.params.tid)
    if not topic_id or topic_id <= 0 then
        return res.render404('此话题不存在或已被删除。')
    end
    local topic = TopicProxy.getTopic(topic_id)
    if not topic then
        return res.render404('此话题不存在或已被删除。')
    end
    topic.lock = topic.lock == 1 and 0 or 1
    topic:save('lock')
    local msg = topic.lock == 1 and '此话题已锁定。' or '此话题已取消锁定。'
    local referer = req.get('referer')
    return res.render('notify/notify', {success = msg, referer = referer})
end

function exports.collect(req, res)
    local topic_id = req.body.topic_id
    topic_id = tonumber(topic_id)
    if not topic_id or topic_id <= 0 then
        return res.json({status = 'failed'})
    end
    local topic = TopicProxy.getTopic(topic_id)
    if not topic then
        return res.json({status = 'failed'})
    end
    local doc = TopicCollectProxy.getTopicCollect(req.session.user.id, topic.id)
    if doc then
        return res.json({status = 'failed'})
    end

    TopicCollectProxy.newAndSave(req.session.user.id, topic.id)
    local user = UserProxy.getUserById(req.session.user.id)
    user.collect_topic_count = user.collect_topic_count+1
    user:save('collect_topic_count')
    req.session.user = user

    topic.collect_count = topic.collect_count+1
    topic:save('collect_count')
    return res.json({status = 'success'})
end

function exports.de_collect(req, res)
    local topic_id = req.body.topic_id
    topic_id = tonumber(topic_id)
    if not topic_id or topic_id <= 0 then
        return res.json({status = 'failed'})
    end
    local topic = TopicProxy.getTopic(topic_id)
    if not topic then
        return res.json({status = 'failed'})
    end
    local removeResult = TopicCollectProxy.remove(req.session.user.id, topic.id)
    if removeResult == 0 then
        return res.json({status = 'failed'})
    end
    local user = UserProxy.getUserById(req.session.user.id)
    user.collect_topic_count = user.collect_topic_count - 1
    user:save('collect_topic_count')
    req.session.user = user

    topic.collect_count = topic.collect_count - 1
    topic:save('collect_count')
    return res.json({status = 'success'})
end

function exports.upload(req, res)
  --     var isFileLimit = false;
  -- var isFileLimit = false;
  -- req.busboy.on('file', function (fieldname, file, filename, encoding, mimetype) {
  --     file.on('limit', function () {
  --       isFileLimit = true;

  --       res.json({
  --         success: false,
  --         msg: 'File size too large. Max is ' + config.file_limit
  --       })
  --     });

  --     store.upload(file, {filename: filename}, function (err, result) {
  --       if (err) {
  --         return next(err);
  --       }
  --       if (isFileLimit) {
  --         return;
  --       }
  --       res.json({
  --         success: true,
  --         url: result.url,
  --       });
  --     });

  --   });
  -- req.pipe(req.busboy);
end

return exports

