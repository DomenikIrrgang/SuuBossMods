SuuBossMods_Plugin = CreateClass()

--[[
	Creates a new plugin.

    @param addonName Name of the addon the plugin belongs to.
    @param pluginName Name the plugin will have in the bossmod.
--]]
function SuuBossMods_Plugin.new(addonName, pluginName)
	local self = setmetatable({}, SuuBossMods_Plugin)
    self.name = pluginName or "DefaultPluginName"
    self.addonName = addonName or "DefaultAddonName"
    self.eventDispatcher = SuuBossMods_EventDispatcher()
    self.combatLogEventDispatcher = SuuBossMods_CombatLogEventDispatcher()
    self.options = {}
    self:addOption("Enabled", "Enables the plugin.", "toggle", self.isEnabled, self.setEnabled)
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

function SuuBossMods_Plugin:load()
    self:loadDefaultSettings()
    if (self:getSettings().enabled == true) then
        self:init()
        self.eventDispatcher:addEventListener(self)
        self.combatLogEventDispatcher:setEnabled(true)
    end
end

function SuuBossMods_Plugin:unload() 
    self.eventDispatcher:clear()
    self.combatLogEventDispatcher:clear()
    self.combatLogEventDispatcher:setEnabled(false)
end

--[[
    Override this function if you want to execute code when the profile has changed.
--]]
function SuuBossMods_Plugin:profileChanged()
    self:init()
end

--[[
    Load plugin settings from profile after the profile has been changed (e.g. copy/import)
--]]
function SuuBossMods_Plugin:PROFILE_CHANGED() 
    self:profileChanged()
end

--[[
    Load plugin settings from profile after it has been initialized.
--]]
function SuuBossMods_Plugin:PROFILE_INIT()
    self:profileChanged()
end

--[[
    Returns the default settings of a plugin. Override this 
    for own settings.

    @return The default settings.
--]]
function SuuBossMods_Plugin:getDefaultSettings()
    return {}
end

function SuuBossMods_Plugin:loadDefaultSettings()
    for key, value in pairs(self:getDefaultSettings()) do
        if (self:getSettings()[key] == nil) then
            self:getSettings()[key] = value
        end
    end
end

function SuuBossMods_Plugin:addOption(name, description, type, get, set, setting1, setting2, setting3, setting4, setting5)
    table.insert(self.options, SuuBossMods_ModuleOption(name, description, type, get, set, self, setting1, setting2, setting3, setting4, setting5))
end

--[[
    Returns the default optionstable of a plugin. Override this 
    for own options.

    @return The optionstable to be registered with the addon options.
--]]
function SuuBossMods_Plugin:getOptionsTable()
    local optionsTable =  {
        type = "group",
        args = {},
        name = "InteruptMonitor",
    }
    for key, option in pairs(self.options) do
        optionsTable.args[option:getName()] = option:getOptionsTable()
    end
    return optionsTable
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
    return self.customEvents
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

function SuuBossMods_Plugin:addEventCallback(combatLogEvent, spellId, callback)
    self.combatLogEventDispatcher:addEventCallback(combatLogEvent, spellId, callback, self)
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
    return SuuBossMods.profileHandler.getProfile().plugins[self.name][key]
end

function SuuBossMods_Plugin:getSettings() 
    return SuuBossMods.profileHandler:getProfile().plugins[self.name]
end

--[[
    Enables/Disables the plugin.
--]]
function SuuBossMods_Plugin:setEnabled(enabled)
    self:getSettings().enabled = enabled
    if (self:getSettings().enabled == true) then
        self:load()
    else
        self:unload()
    end
end

--[[
    Returns true if the plugin is enabled.
--]]
function SuuBossMods_Plugin:isEnabled()
    return self:getSettings().enabled
end