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

_G.shutting_down = false


--- Imports a single photo.
--- @param cat LrCatalog
--- @param exportedPath string path to the exported photo
--- @param sourcePath string path to the source photo
--- @return nil
local function processPhoto(cat, exportedPath, sourcePath)
    if not LrFileUtils.exists(exportedPath) then
        error(("Exported photo does not exist: %q"):format(exportedPath))
    end
    local sourcePhoto = cat:findPhotoByPath(sourcePath)
    if sourcePhoto == nil then
        error(("Source photo not found in catalog: %q"):format(sourcePath))
    end
    Logger:infof("Metadata for %q", sourcePath)
    Utils.logTable(sourcePhoto:getRawMetadata(), "")
    if cat:findPhotoByPath(exportedPath) == nil then
        local leafName = LrPathUtils.leafName(exportedPath)
        cat:withWriteAccessDo(string.format("Importing %s", leafName), function(context)
            local exportedPhoto = cat:addPhoto(exportedPath, sourcePhoto, "above")
            Develop.copyFromSource(exportedPhoto, sourcePhoto)
        end)
    end
end

--- Imports all images contained in the parser result
--- @param context LrFunctionContext
--- @param result ParserResult
--- @return nil
local function processResult(context, result)
    local cat = LrApplication.activeCatalog()
    local total = Utils.tableSize(result.exportedImages)
    local done = 0

    local scope = LrProgressScope({ title = "Importing from PureRAW", functionContext = context })
    scope:setPortionComplete(0, total)

    for exportedPath, sourcePath in pairs(result.exportedImages) do
        processPhoto(cat, exportedPath, sourcePath)

        done = done + 1
        scope:setPortionComplete(done, total)
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
        local import_contents = LrFileUtils.readFile(import_path)
        local parsed = Parser.parse(import_contents)
        Logger:infof("Import file %q parsed containing %d photos", import_path, Utils.tableSize(parsed.exportedImages))
        processResult(context, parsed)
        LrFileUtils.delete(trigger_path)
        LrFileUtils.delete(import_path)
    end
end


--- Top level loop calling singleIteration until shutting down.
--- @param context LrFunctionContext
--- @return nil
local function importLoop(context)
    local temp_path = LrPathUtils.getStandardFilePath("temp")
    local trigger_path = LrPathUtils.child(temp_path, Settings.TriggerFileName)
    local import_path = LrPathUtils.child(temp_path, Settings.ImportFileName)

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

LrFunctionContext.postAsyncTaskWithContext("importLoop", importLoop)
