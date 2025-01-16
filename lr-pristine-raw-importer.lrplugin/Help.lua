-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local LrDialogs = import "LrDialogs"
local LrView = import "LrView"
local Settings = require "Settings"


local viewFactory = LrView.osFactory()
LrDialogs.presentModalDialog {
    title = "Plugin information",
    cancelVerb = "< exclude >",
    contents = viewFactory:row {
        viewFactory:static_text {
            title = Settings.PluginDescription,
        }
    }
}
