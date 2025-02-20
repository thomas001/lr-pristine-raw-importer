-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local LrPrefs = import "LrPrefs"
local LrView = import "LrView"

local Logger = require "Logger"
local Settings = require 'Settings'

local Preferences = {}

--- @enum PureRawVersions
PureRawVersions = { v3 = "v3", v4 = "v4" }

--- @enum StackingMode
StackingMode = { above = "above", below = "below", noStack = "noStack" }


--- @enum CollectionMode
local CollectionMode = {
    addExportedPhoto = "addExportedPhoto",
    addExportedPhotoAndRemoveSource = "addExportedPhotoAndRemoveSource",
    noChange = "noChange",
}

--- @class PluginPreferences
--- @field pureRawVersion PureRawVersions
--- @field stackingMode StackingMode
--- @field collectionMode CollectionMode

--- @param viewFactory LrViewFactory
--- @return LrViewElement
function Preferences.settingsView(viewFactory)
    local prefs = LrPrefs.prefsForPlugin()
    return viewFactory:column {
        bind_to_object = prefs,
        viewFactory:row {
            viewFactory:static_text {
                title = "DxO Pure Raw version",
                aligment = "right",
                width = LrView.share "_label_width",
            },
            viewFactory:popup_menu {
                value = LrView.bind "pureRawVersion",
                items = {
                    { title = "DxO PureRaw v4", value = PureRawVersions.v4 },
                    { title = "DxO PureRaw v3", value = PureRawVersions.v3 },
                },
                width = LrView.share "_control_width",
            },
        },
        viewFactory:row {
            viewFactory:static_text {
                title = "How to stack the exported photo",
                aligment = "right",
                width = LrView.share "_label_width",
            },
            viewFactory:popup_menu {
                value = LrView.bind "stackingMode",
                items = {
                    { title = "Stack above",  value = StackingMode.above },
                    { title = "Stack below",  value = StackingMode.below },
                    { title = "Do not stack", value = StackingMode.noStack },
                },
                width = LrView.share "_control_width",
            },
        },
        viewFactory:row {
            viewFactory:static_text {
                title = "How to update collections",
                aligment = "right",
                width = LrView.share "_label_width",
            },
            viewFactory:popup_menu {
                value = LrView.bind "collectionMode",
                items = {
                    { title = "Add exported photo to the same collections as source photo",                         value = CollectionMode.addExportedPhoto },
                    { title = "Add exported photo to the same collections as source photo and remove source photo", value = CollectionMode.addExportedPhotoAndRemoveSource },
                    { title = "Do not change collections",                                                          value = CollectionMode.noChange },
                },
                width = LrView.share "_control_width",
            },
        },
    }
end

--- @return string
function Preferences.TriggerFileName()
    local prefs = Preferences.prefs()
    return Settings.BaseTriggerFileName .. prefs.pureRawVersion
end

--- @return string
function Preferences.ImportFileName()
    local prefs = Preferences.prefs()
    return Settings.BaseImportFileName .. prefs.pureRawVersion
end

--- @generic T
--- @param prefs table<string, T>
--- @param name string
--- @param type table<T, any>
--- @param default T
--- @return nil
local function checkAndDefault(prefs, name, type, default)
    local value = prefs[name]
    if value == nil then
        prefs[name] = default
    elseif type[value] == nil then
        Logger:errorf("Invalid plugin preferences for %q: %q", name, value)
        prefs[name] = default
    end
end

--- @return nil
function Preferences.init()
    local prefs = LrPrefs.prefsForPlugin()
    checkAndDefault(prefs, "pureRawVersion", PureRawVersions, PureRawVersions.v4)
    checkAndDefault(prefs, "stackingMode", StackingMode, StackingMode.above)
    checkAndDefault(prefs, "collectionMode", CollectionMode, CollectionMode.addExportedPhoto)
end

--- @return PluginPreferences
function Preferences.prefs()
    return LrPrefs.prefsForPlugin()
end

Preferences.PureRawVersions = PureRawVersions
Preferences.StackingMode = StackingMode
Preferences.CollectionMode = CollectionMode

return Preferences
