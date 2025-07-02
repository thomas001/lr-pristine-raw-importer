-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local Utils = require "Utils"
local Logger = require "Logger"
local Preferences = require "Preferences"

local SETTINGS_TO_REVERT = {
    "Sharpness", "SharpenDetail", "SharpenEdgeMasking", "SharpenRadius",
    "EnableLensCorrections", "ChromaticAberrationB", "ChromaticAberrationR",
    "Defringe", "DefringeGreenAmount", "DefringeGreenHueHi", "DefringeGreenHueLo",
    "DefringePurpleAmount", "DefringePurpleHueHi", "DefringePurpleHueLo",
    "ColorNoiseReduction", "ColorNoiseReductionDetail", "ColorNoiseReductionSmoothness",
    "AutoLateralCA",
    "LensProfileEnable", "LensManualDistortionAmount", "LensProfileDistortionScale", "LensProfileVignettingScale",
    "LensProfileSetup",
    "VignetteAmount", "VignetteMidpoint",
}

local FILTERS_TO_REVERT = {
    "$$$/CRaw/Filter/Title/RawDetails=Raw Details",
    "$$$/CRaw/Filter/Title/Denoise=Denoise",
}

local CollectionMode = Preferences.CollectionMode


--- Copies develop settings from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @return nil
local function applyDevelopSettingsFromSource(exportedPhoto, sourcePhoto)
    local settings = Utils.try("Get develop settings for source photo", function()
        return sourcePhoto:getDevelopSettings()
    end)

    for _, s in ipairs(SETTINGS_TO_REVERT) do
        settings[s] = nil
    end
    if settings["WhiteBalance"] == "As Shot" then
        -- Measured white point is different from original RAW and DxO processed
        -- result. Prevent overwriting the adjusted white balance.
        settings["Temperature"] = nil
        settings["Tint"] = nil
    end
    -- The Look setting might set the camera profile. If present in
    -- exportedPhoto, but not in sourcePhoto, then setting CameraProfile will
    -- not work unless we unset Look.
    if settings["Look"] == nil then
        settings["Look"] = {}
    end
    -- FilterList contains a list of named filters. We don't know what could be
    -- in there, so we only selectively revert the ones we know about.
    --- @type {Filters: {Title: string}[]?}?
    local filterList = settings["FilterList"]
    if filterList and filterList.Filters then
        filterList.Filters = Utils.filter(filterList.Filters, function(i, filter)
            return not Utils.containsValue(FILTERS_TO_REVERT, filter.Title)
        end)
    end
    -- Finally, try to set the new settings.
    Utils.try("Apply develop settings to exported photo", function()
        exportedPhoto:applyDevelopSettings(settings, "Apply settings from source photo")
    end)
end

local METADATA_TO_COPY = {
    "rating", "gps", "gpsAltitude", "pickStatus",
}

--- Copies some metadata from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @return nil
local function applyMetadataFromSource(exportedPhoto, sourcePhoto)
    for _, m in ipairs(METADATA_TO_COPY) do
        local val = Utils.try(string.format("Get raw metadata %q", m), function()
            return sourcePhoto:getRawMetadata(m)
        end)
        if val ~= nil then
            Utils.try(string.format("Set raw metadata %q", m), function()
                exportedPhoto:setRawMetadata(m, val)
            end)
        end
    end
    -- colorNameForLabel is special. Copying the default values results in wrong labels.
    local colorNameForLabel = Utils.try(string.format("Get raw metadata 'colorNameForLabel'"), function()
        return sourcePhoto:getRawMetadata("colorNameForLabel")
    end)
    if colorNameForLabel and colorNameForLabel ~= "" and colorNameForLabel ~= "gray" then
        Utils.try("Set raw metadata 'colorNameForLabel'", function()
            exportedPhoto:setRawMetadata("colorNameForLabel", colorNameForLabel)
        end)
    end
end

--- Copies keywords from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @return nil
local function applyKeywordsFromSource(exportedPhoto, sourcePhoto)
    local keywords = Utils.try(string.format("Get raw metadata 'keywords'"), function()
        return sourcePhoto:getRawMetadata("keywords")
    end)
    if keywords == nil then
        return
    end
    for _, kw in ipairs(keywords) do
        Utils.try("Add keyword", function()
            exportedPhoto:addKeyword(kw)
        end)
    end
end

--- Copies collections from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @param mode CollectionMode
--- @return nil
local function applyCollectionsFromSource(exportedPhoto, sourcePhoto, mode)
    local collections = sourcePhoto:getContainedCollections()
    for _, col in ipairs(collections) do
        if mode == CollectionMode.addExportedPhoto then
            Utils.try("Add exported photo to collection", function()
                col:addPhotos({ exportedPhoto })
            end)
        elseif mode == CollectionMode.addExportedPhotoAndRemoveSource then
            Utils.try("Add exported photo to collection", function()
                col:addPhotos({ exportedPhoto })
            end)
            Utils.try("Remove source photo from collection", function()
                col:removePhotos({ sourcePhoto })
            end)
        elseif mode == CollectionMode.noChange then
            -- do nothing
        else
            error(string.format("Unsupported collection mode: %q", mode))
        end
    end
end

--- @param exportedPhoto LrPhoto
--- @param label string|nil
--- @return nil
local function applyCustomLabel(exportedPhoto, label)
    if label == nil or label:len() == 0 then
        return
    end

    Utils.try("Set custom label for photo", function()
        exportedPhoto:setRawMetadata("label", label)
    end)
end

Develop = {}

--- Copies settings, keywords, collections from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @param prefs PluginPreferences
--- @return nil
function Develop.apply(exportedPhoto, sourcePhoto, prefs)
    applyDevelopSettingsFromSource(exportedPhoto, sourcePhoto)
    applyMetadataFromSource(exportedPhoto, sourcePhoto)
    applyKeywordsFromSource(exportedPhoto, sourcePhoto)
    applyCollectionsFromSource(exportedPhoto, sourcePhoto, prefs.collectionMode)
    applyCustomLabel(exportedPhoto, prefs.afterImportLabel)
end

return Develop
