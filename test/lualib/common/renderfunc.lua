-- local Markdown = require "meiru.lib.md"
local filed = require "meiru.lib.filed"
local Markdownd = require "meiru.lib.markdownd"

local config = require "config"
local table = table

local static_host   = config.site_static_host or ""
local static_path   = "./test/assets/static/"
local markdown_path = "./test/assets/markdown/"

--------------------------------------------------
--exports
--------------------------------------------------
local exports = {}

function exports.markdown_file(path)
    local retval = Markdownd.markdown_file(markdown_path..path)
    if retval then
        return '<div class="markdown-text">' .. retval .. '</div>'
    end
    return '<div class="markdown-text"></div>'
end

function exports.staticFile(filePath)
    if filePath:find('http') == 1 or filePath:find('//') == 1 then
        return filePath
    end
    local file_md5 = filed.file_md5(static_path..filePath)
    if file_md5 then
        if filePath:find('?') then
            filePath = filePath.."&fv="..file_md5
        else
            filePath = filePath.."?fv="..file_md5
        end
    else
        log("staticFile not find filePath =", static_path..filePath)
    end
    return static_host .. filePath
end

function exports.tabName(tab)
    for _,v in pairs(config.tabs) do
        if v[1] == tab then
            return v[2]
        end
    end
end

function exports.avatar(url)
    local filePath = "/public/images/skynet_icon.png"
    local file_md5 = filed.file_md5(static_path..filePath)
    filePath = filePath.."?fv="..file_md5
    return filePath
end

local weak_day_names = {"星期日","星期一","星期二","星期三","星期四","星期五","星期六"}
function exports.showDate(ts)
    ts = ts or os.time()
    local date = os.date("*t", ts)
    return os.date("%Y/%m/%d %X", ts)..weak_day_names[date.wday]
end

function exports.Loader(js, css)
    local target = {}
    if js then
        target[io.extname(js)] = js
    end
    if css then
        target[io.extname(css)] = css
    end
    local self = {}
    self.script = {
        assets = {},
        target = target[".js"]
    }
    self.style = {
        assets = {},
        target = target[".css"]
    }

    ------------------------------
    local Loader = self

    function Loader.js(src)
        table.insert(self.script.assets, src)
        return self
    end
    function Loader.css(href)
        table.insert(self.style.assets, href)
        return self
    end
    function Loader.dev(prefix)
        local htmls = {}
        prefix = prefix or ''
        local version = '?v=' .. os.time()
        for _,asset in ipairs(self.script.assets) do
            table.insert(htmls, '<script src="'.. prefix .. asset .. version.. '"></script>\n')
        end
        for _,asset in ipairs(self.style.assets) do
            table.insert(htmls, '<link rel="stylesheet" href="' .. prefix .. asset .. version ..'" media="all" />\n')
        end
        return table.concat(htmls)
    end
    function Loader.pro(CDNMap, prefix)
        if not CDNMap then
            return ""
        end
        prefix = prefix or ''
        local htmls = {}
        local scriptTarget = self.script.target
        if scriptTarget and CDNMap[scriptTarget] then
            table.insert(htmls, '<script src="' .. prefix .. CDNMap[scriptTarget] .. '"></script>\n')
        end
        local styleTarget = self.style.target
        if styleTarget and CDNMap[styleTarget] then
            table.insert(htmls, '<link rel="stylesheet" href="' .. prefix .. CDNMap[styleTarget] .. '" media="all" />\n')
        end
        return table.concat(htmls)
    end
    function Loader.done(CDNMap, prefix, mini)
        prefix = prefix or ""
        if #prefix > 0 and prefix:byte(#prefix) == '/' then
            prefix = prefix:sub(1, #prefix-1)
        end
        return mini and self.pro(CDNMap, prefix) or self.dev(prefix)
    end
    return self
end


return exports