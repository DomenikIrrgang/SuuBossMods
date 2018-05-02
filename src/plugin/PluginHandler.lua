SuuBossMods_PluginHandler = {}
SuuBossMods_PluginHandler.__index = SuuBossMods_PluginHandler

setmetatable(SuuBossMods_PluginHandler, {
    __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
  Creates a new PluginHandler and registers itself as an EventListener.
--]]
function SuuBossMods_PluginHandler.new()
    local self = setmetatable({}, SuuBossMods_PluginHandler)
    self.plugins = {}
    SuuBossMods.eventDispatcher:addEventListener(self)
	return self
end

--[[
  Returns all plugins that have been loaded.

  @return Plugins that have been loaded.
--]]
function SuuBossMods_PluginHandler:getPlugins() 
    return self.plugins
end

--[[
  Loads a plugin.

  @param plugin Plugin that will be loaded.
--]]
function SuuBossMods_PluginHandler:addPlugin(plugin)
    print("plugin added")
    table.insert(self.plugins, plugin)
end

--[[
  Set the default profiles values of all plugins loaded.
--]]
function SuuBossMods_PluginHandler:SUUBOSSMODS_INIT_BEFORE()
    for i, plugin in ipairs(self:getPlugins()) do
	    SuuBossMods.profileHandler:getDefaults()["profile"]["plugins"][plugin.name] = plugin:getDefaultSettings()
	end
end

--[[
  Initialize all plugins after configurations have loaded.
--]]
function SuuBossMods_PluginHandler:SUUBOSSMODS_INIT_AFTER()
    for i, plugin in ipairs(self:getPlugins()) do
        plugin:init()
        SuuBossMods.eventDispatcher:addEventListener(plugin)
	end
end

--[[
    Create the optionstable for all plugins.
--]]
function SuuBossMods_PluginHandler:OPTIONS_TABLE_INIT()
    for i, plugin in ipairs(self:getPlugins()) do
        SuuBossMods.options:addPlugin(plugin)
	end
end

--[[
  Events the pluginhandler should react to.
--]]
function SuuBossMods_PluginHandler:getEvents()
    return {
        "SUUBOSSMODS_INIT_BEFORE",
        "SUUBOSSMODS_INIT_AFTER",
        "OPTIONS_TABLE_INIT",
    }
end
