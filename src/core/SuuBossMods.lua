SuuBossMods = LibStub("AceAddon-3.0"):NewAddon("SuuBossMods", "AceConsole-3.0")

-- Event Dispatcher for all Events. Needs to be first.
SuuBossMods.eventDispatcher = SuuBossMods_EventDispatcher()

-- Provides Profile Data Functionality
SuuBossMods.profileHandler = SuuBossMods_ProfileHandler()
 
-- Provides information about the current dungeon/raid in progress
SuuBossMods.dungeonHandler = SuuBossMods_DungeonHandler()

-- Provides facilties to create modules for dungeons.
SuuBossMods.dungeonModuleLoader = SuuBossMods_DungeonModuleLoader()

-- Provides information about boss encounters
SuuBossMods.encounterHandler = SuuBossMods_EncounterHandler()

-- Provides facilities to create modules for boss encounters
SuuBossMods.encounterModuleLoader = SuuBossMods_EncounterModuleLoader()

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
function SuuBossMods:chatMessage(message)
	print("|c0000FF00SuuBossMods|r: "..message)
end
