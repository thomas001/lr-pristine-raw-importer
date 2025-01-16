-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local Settings = require "Settings"

--- @param viewFactory LrViewFactory
--- @param propertyTable table
--- @return {title: string, synopsis: string, [integer]: LrView}[]
local function sectionsForTopOfDialog(viewFactory, propertyTable)
    return { {
        title = "Plugin Information",
        viewFactory:row {
            viewFactory:static_text {
                title = Settings.PluginDescription,
            }
        }
    } }
end

return {
    sectionsForTopOfDialog = sectionsForTopOfDialog,
}
