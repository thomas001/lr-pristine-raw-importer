return {
    VERSION = { major = 1, minor = 0, revision = 0 },
    LrSdkVersion = 14.0,
    LrToolkitIdentifier = "com.github.thomas001.lr-pristine-raw-importer",
    LrPluginName = "Pristine RAW Importer",
    LrPluginInfoUrl = "https://github.com/thomas001/lr-pristine-raw-importer",
    LrPluginInfoProvider = "PluginInfoProvider.lua",

    LrInitPlugin = "Init.lua",
    LrForceInitPlugin = true,
    LrShutdownPlugin = "Shutdown.lua",

    -- We need a menu item so the plugin is loaded at all.
    LrHelpMenuItems = {
        { title = "About Pristine RAW Importer", file = "Help.lua" }
    }

}
