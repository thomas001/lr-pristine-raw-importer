-- Copyright (c) 2025 Thomas Weidner. All rights reserved.
-- Licensed under the Apache License, Version 2.0. See LICENSE for details.

--- A minimal set of type annotations for Lightroom's Lua SDK.
--- Just enough to get this plugin type checked.

--- @meta Lightroom

--- @param name "LrLogger"
--- @return fun(loggerName: string): LrLogger
--- @overload fun(name: "LrStringUtils"): LrStringUtils
--- @overload fun(name: "LrFunctionContext"): LrFunctionContext
--- @overload fun(name: "LrTasks"): LrTasks
--- @overload fun(name: "LrPathUtils"): LrPathUtils
--- @overload fun(name: "LrFileUtils"): LrFileUtils
--- @overload fun(name: "LrDialogs"): LrDialogs
--- @overload fun(name: "LrApplication"): LrApplication
--- @overload fun(name: "LrProgressScope"): (fun(params: LrProgressScopeParams): LrProgressScope)
--- @overload fun(name: "LrView"): LrView
--- @overload fun(name: "LrPrefs"): LrPrefs
function import(name) end

--- @class LrLogger
LrLogger = {}

--- @param logType  string
function LrLogger:enable(logType) end

--- @param s string
function LrLogger:trace(s) end

--- @param s string
function LrLogger:tracef(s, ...) end

--- @param s string
function LrLogger:info(s) end

--- @param s string
function LrLogger:infof(s, ...) end

--- @param s string
function LrLogger:error(s) end

--- @param s string
function LrLogger:errorf(s, ...) end

--- @class LrStringUtils
LrStringUtils = {}


--- @param s string
--- @return string
function LrStringUtils.trimWhitespace(s) end

--- @class LrKeyword
LrKeyword = {}

--- @class LrPhoto
LrPhoto = {}

--- @param k LrKeyword
function LrPhoto:addKeyword(k) end

--- @class LrUnspecified
LrUnspecified = {}

--- @return {[string]: LrUnspecified}
--- @overload fun(self: LrPhoto, m: "keywords"): LrKeyword[] | nil
--- @overload fun(self: LrPhoto, m: string): LrUnspecified | nil
function LrPhoto:getRawMetadata() end

-- Requires SDK 10.3
--- @return boolean
function LrPhoto:copySettings() end

-- Requires SDK 10.3
--- @param updateAISettings? boolean
--- @return boolean
function LrPhoto:pasteSettings(updateAISettings) end

--- @return {[string]: LrUnspecified}
function LrPhoto:getDevelopSettings() end

--- @param settings {[string]: LrUnspecified}
--- @param historyName? string
--- @param flattenAutoNow? boolean
function LrPhoto:applyDevelopSettings(settings, historyName, flattenAutoNow) end

--- @param m string
--- @return string
function LrPhoto:getFormattedMetadata(m) end

--- @param m string
--- @param v any
function LrPhoto:setRawMetadata(m, v) end

--- @return LrCollection[]
function LrPhoto:getContainedCollections() end

--- @class LrCollection
LrCollection = {}

--- @param photos LrPhoto[]
function LrCollection:addPhotos(photos) end

--- @param photos LrPhoto[]
function LrCollection:removePhotos(photos) end

--- @class LrFunctionContext
LrFunctionContext = {}

--- @param name string
--- @param func fun(context: LrFunctionContext)
function LrFunctionContext.postAsyncTaskWithContext(name, func) end

--- @generic R
--- @param name string
--- @param func fun(context: LrFunctionContext,...): R
--- @return boolean success
--- @return R result
--- @overload fun(name: string, func: fun(context: LrFunctionContext, ...): nil, ...): boolean
function LrFunctionContext.pcallWithContext(name, func, ...) end

--- @param func fun(success: boolean, msg: string): nil
function LrFunctionContext:addFailureHandler(func) end

--- @class LrTasks
LrTasks = {}

--- @param d number
--- @return nil
function LrTasks.sleep(d) end

--- @generic T
--- @param fn function
--- @param ... any
--- @return boolean success
--- @return any ...
function LrTasks.pcall(fn, ...) end

--- @class LrPathUtils
LrPathUtils = {}

--- @param path string
--- @return string
function LrPathUtils.leafName(path) end

--- @param p1 string
--- @param p2 string
--- @return string
function LrPathUtils.child(p1, p2) end

--- @param kind string
--- @return string
function LrPathUtils.getStandardFilePath(kind) end

--- @class LrFileUtils
LrFileUtils = {}

--- @param path string
--- @return boolean
function LrFileUtils.exists(path) end

--- @param path string
--- @return string
function LrFileUtils.readFile(path) end

--- @param path string
--- @return nil
function LrFileUtils.delete(path) end

--- @class LrDialogs
LrDialogs = {}

--- @param context LrFunctionContext
--- @return nil
function LrDialogs.attachErrorDialogToFunctionContext(context) end

--- @param message string
--- @param info? string
--- @param style? string
--- @return nil
function LrDialogs.message(message, info, style) end

--- @param args {title: string, resizable?: boolean|string, contents: LrViewElement, actionVerb?: string, cancelVerb?: string, otherVerb?: string}
--- @return string
function LrDialogs.presentModalDialog(args) end

--- @class LrApplication
LrApplication = {}

--- @return LrCatalog
function LrApplication.activeCatalog() end

--- @class LrTasks
LrTasks = {}

--- @alias LrProgressScopeParams {
---   parent?: LrProgressScope,
---   parentEndRange?: number,
---   title?: string,
---   caption?: string,
---   functionContext?: LrFunctionContext,
--- }

--- @class LrProgressScope
LrProgressScope = {}

--- @param done number
--- @param total? number
function LrProgressScope:setPortionComplete(done, total) end

--- @class LrCatalog
LrCatalog = {}

--- @param path string
--- @param caseSensitivity? any
--- @return LrPhoto | nil
function LrCatalog:findPhotoByPath(path, caseSensitivity) end

--- @param name string
--- @param func fun(context: LrFunctionContext): nil
--- @param timeoutParams? {timeout: number, callback?: (fun(): nil), asynchronous? :boolean}
--- @return nil
function LrCatalog:withWriteAccessDo(name, func, timeoutParams) end

--- @param path string
--- @param stackWithPhoto? LrPhoto
--- @param position? string
--- @param metadataPresetUUID? string
--- @param developPresetUUID? string
--- @return LrPhoto
function LrCatalog:addPhoto(path, stackWithPhoto, position, metadataPresetUUID, developPresetUUID) end

--- @class LrView
LrView = {}

--- @return LrViewFactory
function LrView.osFactory() end

--- @class LrViewBinding

--- @class LrViewBindingArgs
--- @field key string
--- @field bind_to_object? string
--- @field transform? fun(any, boolean)any


--- @param args string|LrViewBindingArgs
--- @return LrViewBinding
function LrView.bind(args) end

--- @param args string
--- @return LrViewBinding
function LrView.share(args) end

--- @class LrViewFactory
LrViewFactory = {}

--- @param args {[integer]: LrViewElement}
--- @return LrViewElement
function LrViewFactory:row(args) end

--- @param args {[integer]: LrViewElement}
--- @return LrViewElement
function LrViewFactory:column(args) end

--- @param args {[integer]: LrViewElement}
--- @return LrViewElement
function LrViewFactory:view(args) end

--- @param args {[integer]: LrViewElement}
--- @return LrViewElement
function LrViewFactory:combo_box(args) end

--- @param args {[integer]: LrViewElement}
--- @return LrViewElement
function LrViewFactory:popup_menu(args) end

--- @param args {[integer]: LrViewElement}
--- @return LrViewElement
function LrViewFactory:checkbox(args) end

--- @param args {title?: string, truncation?: string, selectable?: boolean, alignment?: string}
--- @return LrViewElement
function LrViewFactory:static_text(args) end

--- @class LrViewElement
LrViewElement = {}


--- @class LrPrefs
LrPrefs = {}

--- @return table<string, any>
function LrPrefs.prefsForPlugin() end
