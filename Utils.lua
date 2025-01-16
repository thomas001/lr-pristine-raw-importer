local Logger = require "Logger"

local Utils = {}

--- @param tbl table<any,any>
--- @return number
function Utils.tableSize(tbl)
    local c = 0
    for k, v in pairs(tbl) do
        c = c + 1
    end
    return c
end

--- @param tbl table<any,any>
--- @param prefix string
function Utils.logTable(tbl, prefix)
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            Logger:infof("%s%s = {", prefix, k)
            --- @cast v table
            Utils.logTable(v, prefix .. "    ")
            Logger:infof("%s}", prefix)
        else
            Logger:infof("%s%s = %q", prefix, k, v)
        end
    end
end

return Utils
