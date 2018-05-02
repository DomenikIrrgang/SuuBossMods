SuuBossMods = LibStub("AceAddon-3.0"):NewAddon("SuuBossMods", "AceConsole-3.0")

-- Event Dispatcher for all Events. Needs to be first.
SuuBossMods.eventDispatcher = SuuBossMods_EventDispatcher()

-- Addon options.
SuuBossMods.options = SuuBossMods_Options()

-- Profile Data Functionality
SuuBossMods.profileHandler = SuuBossMods_ProfileHandler()
 
-- Handles all plugins of the addon.
SuuBossMods.pluginHandler = SuuBossMods_PluginHandler()

function SuuBossMods:OnInitialize()
    self.eventDispatcher:dispatchEvent("SUUBOSSMODS_INIT_BEFORE")
    self.eventDispatcher:dispatchEvent("SUUBOSSMODS_INIT")
    self.eventDispatcher:dispatchEvent("SUUBOSSMODS_INIT_AFTER")
end

--[[
    Prints a message using the bossmod.
--]]
function SuuBossMods:ChatMessage(message)
	print("|c0000FF00SuuBossMods|r: "..message)
end