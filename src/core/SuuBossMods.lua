SuuBossMods = LibStub("AceAddon-3.0"):NewAddon("SuuBossMods", "AceConsole-3.0")

-- Event Dispatcher for all Events. Needs to be first.
SuuBossMods.eventDispatcher = SuuBossMods_EventDispatcher()

-- Profile Data Functionality
SuuBossMods.profileHandler = SuuBossMods_ProfileHandler()
 
-- Addon options.
SuuBossMods.options = SuuBossMods_Options()

function SuuBossMods:OnInitialize()
    -- Handles all plugins of the addon.
    SuuBossMods.pluginHandler = SuuBossMods_PluginHandler()
    
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
