-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local LrTasks = import "LrTasks"
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

--- @generic T
--- @param what string
--- @param fn fun(): T
--- @return T
--- @overload fun(what: string, fn: fun())
function Utils.try(what, fn)
    local ok, r = LrTasks.pcall(fn)
    if ok then
        return r
    else
        error(string.format("Failed: %s: %s", what, r))
    end
end

---@param lst any[]
---@param val any
---@return boolean
function Utils.containsValue(lst, val)
    for _, v in pairs(lst) do
        if v == val then
            return true
        end
    end
    return false
end

---@generic K, V
---@param tbl table<K,V>
---@param predicate fun(k: K, v:V): boolean
---@return table<K,V>
function Utils.filter(tbl, predicate)
    -- Lua LS seems to no t work with generics correctly here, so we need to
    -- explicitly type them as "any" to prevent type check errors.

    ---@type table<any,any>
    local r = {}
    ---@type table<any,any>
    local t = tbl
    for k, v in pairs(t) do
        if predicate(k, v) then
            r[k] = v
        end
    end
    return r
end

return Utils
