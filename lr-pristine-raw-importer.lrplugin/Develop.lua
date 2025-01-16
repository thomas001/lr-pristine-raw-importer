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
    -- 1. Store import settings
    local exportedSettings = exportedPhoto:getDevelopSettings()
    -- 2. Copy settings from source photo
    -- Using copySettings/pasteSettings is much more stable, but we need to revert some pasted settings
    local ok = sourcePhoto:copySettings()
    if not ok then
        error(("Could not copy settings from %q"):format(sourcePhoto:getFormattedMetadata("fileName")))
    end
    ok = exportedPhoto:pasteSettings()
    if not ok then
        error(("Could not paste settings to %1"):format(exportedPhoto:getFormattedMetadata("fileName")))
    end
    -- 3. Update settings
    local newSettings = {} --- @type {[string]:LrUnspecified}
    for _, s in ipairs(SETTINGS_TO_REVERT) do
        newSettings[s] = exportedSettings[s]
    end
    exportedPhoto:applyDevelopSettings(newSettings)
end

local METADATA_TO_COPY = {
    "rating", "colorNameForLabel",
    "gps", "gpsAltitude", "pickStatus"
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
