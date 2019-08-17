
local skynet = require "skynet"
local fuckforbid = require "config.fuckforbid"
local string = string

function string.split(input, sep)
    local retval = {}
    string.gsub(input, string.format("([^%s]+)", (sep or "\t")), function(c)
        table.insert(retval, c)
    end)
    return retval
end

local command = {}

function command.chech_invalid(txt)
    local lines = string.split(txt, "\n")
    for _,line in ipairs(lines) do
        for _,pattern in ipairs(fuckforbid) do
            if string.match(line, pattern) then
                return true
            end
        end
    end
end

function command.cenvert_valid(txt)
    local lines = string.split(txt, "\n")
    local contents = {}
    for _,line in ipairs(lines) do
        for _,pattern in ipairs(fuckforbid) do
            line = string.gsub(line, pattern, function(tmp)
                skynet.error("pattern =", pattern, "tmp =", tmp)
                return string.rep("$", utf8.len(tmp))
            end)
        end
        table.insert(contents, line)
    end
    return table.concat(contents, "\n")
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_,cmd,...)
        local f = command[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            assert(false, "error no support cmd"..cmd)
        end
    end)
end)

