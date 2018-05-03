SuuBossMods_EncounterModule = CreateClass()

function SuuBossMods_EncounterModule.new(encounterName, encounterId)
    local self = setmetatable({}, SuuBossMods_EncounterModule)
    self.encounterId = encounterId
    self.gameEvents = {}
    self.encounterName = encounterName
    self.customEvents = {}
    return self
end

function SuuBossMods_EncounterModule:init()
end

function SuuBossMods_EncounterModule:unload()
end

function SuuBossMods_EncounterModule:getOptionsTable()
	return {
		name = self.encounterName,
		type = "group",
        order = 1,
        args = {},
    }
end

function SuuBossMods_EncounterModule:getName()
    return self.encounterName
end

--[[
    Returns the events the module should react to. Override for 
    changing the events to react to.
--]]
function SuuBossMods_EncounterModule:getGameEvents()
    return self.gameEvents
end

--[[
    Returns the events the module should react to. Override for 
    changing the events to react to.
--]]
function SuuBossMods_EncounterModule:getCustomEvents()
    return self.customEvents
end

--[[
    Adds an event the module will react to.

    @param event Event that will be added.
--]]
function SuuBossMods_EncounterModule:addGameEvent(event)
    table.insert(self.gameEvents, event)
end

--[[
    Adds an event the module will react to.

    @param event Event that will be added.
--]]
function SuuBossMods_EncounterModule:addCustomEvent(event)
    table.insert(self.customEvents, event)
end