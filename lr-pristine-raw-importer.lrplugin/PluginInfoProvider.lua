-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local LrView = import "LrView"

local Settings = require "Settings"
local Preferences = require "Preferences"



--- @param viewFactory LrViewFactory
--- @param propertyTable table
--- @return {title: string, synopsis: string, [integer]: LrView}[]
local function sectionsForTopOfDialog(viewFactory, propertyTable)
    return {
        {
            title = "Plugin Information",
            viewFactory:row {
                viewFactory:static_text {
                    title = Settings.PluginDescription,
                },
            },
        },
        {
            title = "Settings",
            Preferences.settingsView(viewFactory),
        },
    }
end

return {
    sectionsForTopOfDialog = sectionsForTopOfDialog,
}
