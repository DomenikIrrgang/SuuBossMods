SuuBossMods_Plugin = {}
SuuBossMods_Plugin.__index = SuuBossMods_Plugin

setmetatable(SuuBossMods_Plugin, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
	Creates a new plugin.

    @param addonName Name of the addon the plugin belongs to.
    @param pluginName Name the plugin will have in the bossmod.
--]]
function SuuBossMods_Plugin.new(addonName, pluginName)
	local self = setmetatable({}, SuuBossMods_Plugin)
    self.name = pluginName or "DefaultPluginName"
    self.addonName = addonName or "DefaultAddonName"
    self.enabled = true
    self.gameEvents = {
    }
    self.customEvents = {
        "PROFILE_CHANGED",
        "PROFILE_INIT",
    }
	return self
end

--[[
    Override this function if you want to get called when the BossMod has been initialized.
--]]
function SuuBossMods_Plugin:init()
end

function SuuBossMods_Plugin:loaded() 
        self:init()
        SuuBossMods.eventDispatcher:addEventListener(self)
end

--[[
    Load plugin settings from the currently active profile.
--]]
function SuuBossMods_Plugin:loadFromProfile()
    self.enabled = self:getProfileValue("enabled")
    self:profileChanged()
end

--[[
    Override this function if you want to execute code when the profile has changed.
--]]
function SuuBossMods_Plugin:profileChanged()
end

--[[
    Load plugin settings from profile after the profile has been changed (e.g. copy/import)
--]]
function SuuBossMods_Plugin:PROFILE_CHANGED() 
    self:loadFromProfile()
end

--[[
    Load plugin settings from profile after it has been initialized.
--]]
function SuuBossMods_Plugin:PROFILE_INIT()
    self:loadFromProfile()
end

--[[
    Returns the default settings of a plugin. Override this 
    for own settings.

    @return The default settings.
--]]
function SuuBossMods_Plugin:getDefaultSettings()
    return {}
end

--[[
    Returns the default optionstable of a plugin. Override this 
    for own options.

    @return The optionstable to be registered with the addon options.
--]]
function SuuBossMods_Plugin:getOptionsTable()
    return {}
end

--[[
    Returns the name of the plugin.
--]]
function SuuBossMods_Plugin:getName()
    return self.name
end

--[[
    Returns the name of the plugin.
--]]
function SuuBossMods_Plugin:getAddonName()
    return self.addonName
end

--[[
    Returns the events the plugin should react to. Override for 
    changing the events to react to.
--]]
function SuuBossMods_Plugin:getGameEvents()
    return self.gameEvents
end

--[[
    Returns the events the plugin should react to. Override for 
    changing the events to react to.
--]]
function SuuBossMods_Plugin:getCustomEvents()
    return self.gameEvents
end

--[[
    Adds an event the plugin will react to.

    @param event Event that will be added.
--]]
function SuuBossMods_Plugin:addGameEvent(event)
    table.insert(self.gameEvents, event)
end

--[[
    Adds an event the plugin will react to.

    @param event Event that will be added.
--]]
function SuuBossMods_Plugin:addCustomEvent(event)
    table.insert(self.customEvents, event)
end

--[[
    Changes the value of a profile value.

    @param key Name of the profile value.
    @param value New value for the profile value.
--]]
function SuuBossMods_Plugin:setProfileValue(key, value)
    SuuBossMods.profileHandler.db.profile.plugins[self.name][key] = value
end

--[[
    Returns the current profile value of a given key.

    @return Value of the given profile value key.
--]]
function SuuBossMods_Plugin:getProfileValue(key, value)
    return SuuBossMods.profileHandler.db.profile.plugins[self.name][key]
end

--[[
    Enables the profile.
--]]
function SuuBossMods_Plugin:enable()
    self.enabled = true
    self:setProfileValue("enabled", true)
end

--[[
    Disables the profile.
--]]
function SuuBossMods_Plugin:disable()
    self.enabled = false
    self:setProfileValue("enabled", false)
end

--[[
    Returns true if the plugin is enabled.
--]]
function SuuBossMods_Plugin:isEnabled()
    return self.enabled
end