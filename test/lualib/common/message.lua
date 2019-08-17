

local exports = {}


  --  ignoreRegexs = [
  --   /```.+?```/g, // 去除单行的 ```
  --   /^```[\s\S]+?^```/gm, // ``` 里面的是 pre 标签内容
  --   /`[\s\S]+?`/g, // 同一行中，`some code` 中内容也不该被解析
  --   /^    .*/gm, // 4个空格也是 pre 标签，在这里 . 不会匹配换行
  --   /\b\S*?@[^\s]*?\..+?\b/g, // somebody@gmail.com 会被去除
  --   /\[@.+?\]\(\/.+?\)/g, // 已经被 link 的 username
  --   /\/@/g, // 一般是url中path的一部分
  -- ];


local function fetchUsers(text) 
    if type(text) ~= "string" or #text == 0 then
        return {}
    end

    local ignoreRegexs = {
        "```.+```", -- 去除单行的 ```
    	-- /^```[\s\S]+?^```/gm, // ``` 里面的是 pre 标签内容
        "`.+`", -- 同一行中，`some code` 中内容也不该被解析
        "^    .*", -- 4个空格也是 pre 标签，在这里 . 不会匹配换行
        "[%w%p]+@[%w%p]+", -- somebody@gmail.com 会被去除
        -- "%[@.+?%]%(%/.+?%)", -- 已经被 link 的 username
    }
    for _,ignoreRegex in ipairs(ignoreRegexs) do
        text = string.gsub(text, ignoreRegex, "")
    end
    local names = {}
    for name in string.gmatch(text, "@[%w%p]+%s") do
        table.insert(names, string.sub(name, 2, #name-1))
    end
    return names;
end

exports.fetchUsers = fetchUsers

function exports.linkUsers(text) 
    local names = fetchUsers(text)
    for _,name in ipairs(names) do
		text = string.gsub(text, "@["..name.."]+%s" , "["..name.."](/user/"..name..")")
    end
    return text
end

function exports.sendMessageToMentionUsers(text, topicId, authorId, reply_id)
    local UserProxy = require "proxy.user"
    local names = fetchUsers(text)
    if #names == 0 then
        return
    end
    local users = UserProxy.getUsersByNames(names)
    for _,user in ipairs(users) do
        if user.id ~= authorId then
            exports.sendAtMessage(user.id, authorId, topicId, reply_id)
        end
    end
end

function exports.sendReplyMessage(master_id, author_id, topic_id, reply_id)
	local MessageProxy = require "proxy.message"
    MessageProxy.newAndSave("reply", master_id, author_id, topic_id, reply_id)
end

function exports.sendAtMessage(master_id, author_id, topic_id, reply_id)
	local MessageProxy = require "proxy.message"
    MessageProxy.newAndSave("at", master_id, author_id, topic_id, reply_id)
end


return exports

