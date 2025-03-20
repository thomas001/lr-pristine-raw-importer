-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local LrFunctionContext = import "LrFunctionContext"
local LrTasks = import "LrTasks"
local LrPathUtils = import "LrPathUtils"
local LrFileUtils = import "LrFileUtils"
local LrDialogs = import "LrDialogs"
local LrApplication = import "LrApplication"
local LrProgressScope = import "LrProgressScope"

local Settings = require "Settings"
local Parser = require "Parser"
local Develop = require "Develop"
local Logger = require "Logger"
local Utils = require "Utils"
local Preferences = require "Preferences"

local StackingMode = Preferences.StackingMode

_G.shutting_down = false

--- @param cat LrCatalog
--- @param exportedPath string
--- @param sourcePhoto LrPhoto
--- @param mode StackingMode
--- @return LrPhoto
local function addPhoto(cat, exportedPath, sourcePhoto, mode)
    if mode == StackingMode.above then
        return cat:addPhoto(exportedPath, sourcePhoto, "above")
    elseif mode == StackingMode.below then
        return cat:addPhoto(exportedPath, sourcePhoto, "below")
    elseif mode == StackingMode.noStack then
        return cat:addPhoto(exportedPath)
    else
        error(string.format("Invalid stacking mode: %q", mode))
    end
end

--- Imports a single photo.
--- @param cat LrCatalog
--- @param exportedPath string path to the exported photo
--- @param sourcePath string path to the source photo
--- @param prefs PluginPreferences
--- @return LrPhoto|nil
local function processPhoto(cat, exportedPath, sourcePath, prefs)
    if not LrFileUtils.exists(exportedPath) then
        local msg = string.format("Exported photo does not exist: %q", exportedPath)
        Logger:error(msg)
        LrDialogs.message(msg)
        return
    end
    local sourcePhoto = cat:findPhotoByPath(sourcePath)
    if sourcePhoto == nil then
        local msg = string.format("Source photo not found in catalog: %q", sourcePath)
        Logger:error(msg)
        LrDialogs.message(msg)
        return
    end
    if cat:findPhotoByPath(exportedPath) == nil then
        local leafName = LrPathUtils.leafName(exportedPath)
        local exportedPhoto = nil
        cat:withWriteAccessDo(string.format("Importing %s", leafName), function(context)
            exportedPhoto = Utils.try("Add exported photo to catalog", function()
                return addPhoto(cat, exportedPath, sourcePhoto, prefs.stackingMode)
            end)
            Develop.apply(exportedPhoto, sourcePhoto, prefs)
        end)
        return exportedPhoto
    end
end

--- Imports all images contained in the parser result
--- @param context LrFunctionContext
--- @param result ParserResult
--- @return nil
local function processResult(context, result)
    local prefs = Preferences.prefs()

    local cat = LrApplication.activeCatalog()
    local total = Utils.tableSize(result.exportedImages)
    local done = 0

    local scope = LrProgressScope({ title = "Importing from PureRAW", functionContext = context })
    scope:setPortionComplete(0, total)

    local exportedPhotos = {}
    for exportedPath, sourcePath in pairs(result.exportedImages) do
        local exportedPhoto = processPhoto(cat, exportedPath, sourcePath, prefs)
        if exportedPhoto then
            table.insert(exportedPhotos, exportedPhoto)
        end

        done = done + 1
        scope:setPortionComplete(done, total)
    end

    if prefs.afterImportSelect and #exportedPhotos > 0 then
        Utils.try("Updating selected photos", function()
            cat:setSelectedPhotos(exportedPhotos[1], exportedPhotos)
        end)
    end
end

--- Runs a single iteration of the import loop.
--- @param context LrFunctionContext
--- @param trigger_path string path of the trigger file
--- @param import_path string path of the import file
--- @return nil
local function singleIteration(context, trigger_path, import_path)
    if LrFileUtils.exists(trigger_path) then
        Logger:infof("Trigger file %q detected", trigger_path)
        local import_contents = Utils.try("Read PureRAW import file", function()
            return LrFileUtils.readFile(import_path)
        end)
        local parsed = Parser.parse(import_contents)
        Logger:infof("Import file %q parsed containing %d photos", import_path, Utils.tableSize(parsed.exportedImages))
        processResult(context, parsed)
        Utils.try("Delete PureRAW trigger files", function()
            LrFileUtils.delete(trigger_path)
            LrFileUtils.delete(import_path)
        end)
    end
end


--- Top level loop calling singleIteration until shutting down.
--- @param context LrFunctionContext
--- @return nil
local function importLoop(context)
    local temp_path = LrPathUtils.getStandardFilePath("temp")
    local trigger_path = LrPathUtils.child(temp_path, Preferences.TriggerFileName())
    local import_path = LrPathUtils.child(temp_path, Preferences.ImportFileName())

    Logger:info("Import loop started")
    while not _G.shutting_down do
        LrFunctionContext.pcallWithContext("singleIteration", function(context)
            context:addFailureHandler(function(success, err)
                if success then
                    return
                end
                Logger:errorf("Import failure: %s", err)
                -- Shut down the plugin so the error does not repeat over and
                -- over again.
                _G.shutting_down = true
            end)
            LrDialogs.attachErrorDialogToFunctionContext(context)
            singleIteration(context, trigger_path, import_path)
        end)

        LrTasks.sleep(1)
    end
    Logger:info("Import loop finished")
end

Preferences.init()

LrFunctionContext.postAsyncTaskWithContext("importLoop", importLoop)
