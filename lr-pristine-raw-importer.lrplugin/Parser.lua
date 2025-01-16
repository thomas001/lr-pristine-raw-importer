-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

local LrStringUtils = import "LrStringUtils"

local Logger = require "Logger"


local Parser = {}


--- @alias ParserResult {exportedImages: {[string]: string}} Mapping of exported image to source image path

--- Parses a PureRaw import file
--- @param import_contents string the contents of the file
--- @return ParserResult
function Parser.parse(import_contents)
    local seen_collection_name = false --- @type boolean
    local source_images = {}           --- @type string[]
    local destination_images = {}      --- @type {[string]: string}

    --- Parses a line looking for the collection name.
    ---
    --- Will return success until the collection name has been found, since the collection name
    --- is at the start of the import file.
    ---
    --- @param line string the line to parse
    --- @return boolean whether the line could be parsed successfully
    local function tryCollectionName(line)
        if line:match("END_OF_COLLECTION_NAME_SECTION$") then
            seen_collection_name = true
            return true
        end
        if seen_collection_name then
            return false
        end
        return true
    end

    --- Parses a line starting with +. Maybe some options?
    --- @param line string the line to parse
    --- @return boolean whether the line could be parsed successfully
    local function tryMysteryLine(line)
        local m = line:match("^%+")
        return (m ~= nil)
    end

    --- Parses a line designating a source image.
    --- @param line string the line to parse
    --- @return boolean whether the line could be parsed successfully
    local function trySourceImage(line)
        local source_image = line:match("^%-%s+(.+)$")
        if source_image == nil then
            return false
        end

        source_image = LrStringUtils.trimWhitespace(source_image)
        table.insert(source_images, source_image)
        return true
    end

    --- Parses a line designating an exported image.
    --- @param line string the line to parse
    --- @return boolean whether the line could be parsed successfully
    local function tryExportedImage(line)
        local source_index, export_path = line:match("^(%d+)%s+(.+)$")
        if source_index == nil then
            return false
        end

        export_path = LrStringUtils.trimWhitespace(export_path)
        source_index = tonumber(source_index)
        if source_index == nil then
            -- Failed to convert string to number
            error(("Failed to convert index: %q"):format(line))
        end
        if source_index + 1 > #source_images then
            error(("Invalid source index encountered in line: %q"):format(line))
        end
        local source_image = source_images[source_index + 1]
        local existing_image = destination_images[export_path]
        if existing_image ~= nil and existing_image ~= source_image then
            error(("Conflicting source images for %q: %q and %q"):format(export_path, source_image, existing_image))
        end

        destination_images[export_path] = source_image

        return true
    end

    for line in import_contents:gmatch("([^\n]*)\n?") do
        line = LrStringUtils.trimWhitespace(line)
        if #line > 0 then
            local parsed = (
                tryCollectionName(line)
                or tryMysteryLine(line)
                or trySourceImage(line)
                or tryExportedImage(line))
            if not parsed then
                error(("Could not parse line: %q"):format(line))
            end
        end
    end

    if not seen_collection_name then
        error("No END_OF_COLLECTION_NAME_SECTION in file")
    end

    Logger:trace("Parsed image mapping:")
    for k, v in pairs(destination_images) do
        Logger:tracef("  %q => %q", k, v)
    end

    return {
        exportedImages = destination_images
    }
end

return Parser
