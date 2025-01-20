-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

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

--- Copies develop settings from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @return nil
local function applyDevelopSettingsFromSource(exportedPhoto, sourcePhoto)
    local settings = sourcePhoto:getDevelopSettings()

    for _, s in ipairs(SETTINGS_TO_REVERT) do
        settings[s] = nil
    end
    if settings["WhiteBalance"] == "As Shot" then
        -- Measured white point is different from original RAW and DxO processed
        -- result. Prevent overwriting the adjusted white balance.
        settings["Temperature"] = nil
        settings["Tint"] = nil
    end
    exportedPhoto:applyDevelopSettings(settings, "Apply settings from source photo")
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
        local val = sourcePhoto:getRawMetadata(m)
        if val ~= nil then
            exportedPhoto:setRawMetadata(m, val)
        end
    end
    -- colorNameForLabel is special. Copying the default values results in wrong labels.
    local colorNameForLabel = sourcePhoto:getRawMetadata("colorNameForLabel")
    if colorNameForLabel and colorNameForLabel ~= "" and colorNameForLabel ~= "gray" then
        exportedPhoto:setRawMetadata("colorNameForLabel", colorNameForLabel)
    end
end

--- Copies keywords from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @return nil
local function applyKeywordsFromSource(exportedPhoto, sourcePhoto)
    local keywords = sourcePhoto:getRawMetadata("keywords")
    if keywords == nil then
        return
    end
    for _, kw in ipairs(keywords) do
        exportedPhoto:addKeyword(kw)
    end
end

--- Copies collections from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @return nil
local function applyCollectionsFromSource(exportedPhoto, sourcePhoto)
    local collections = sourcePhoto:getContainedCollections()
    for _, col in ipairs(collections) do
        col:addPhotos({ exportedPhoto })
    end
end

Develop = {}

--- Copies settings, keywords, collections from source to exported photo.
--- @param exportedPhoto  LrPhoto
--- @param sourcePhoto LrPhoto
--- @return nil
function Develop.copyFromSource(exportedPhoto, sourcePhoto)
    applyDevelopSettingsFromSource(exportedPhoto, sourcePhoto)
    applyMetadataFromSource(exportedPhoto, sourcePhoto)
    applyKeywordsFromSource(exportedPhoto, sourcePhoto)
    applyCollectionsFromSource(exportedPhoto, sourcePhoto)
end

return Develop
