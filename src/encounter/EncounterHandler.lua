SuuBossMods_EncounterHandler = {}
SuuBossMods_EncounterHandler.__index = SuuBossMods_EncounterHandler

setmetatable(SuuBossMods_EncounterHandler, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
  Creates a new EncounterHandler and registers itself as a EventListener.
--]]
function SuuBossMods_EncounterHandler.new()
    local self = setmetatable({}, SuuBossMods_EncounterHandler)
    self.encounterHistory = {}
    SuuBossMods.eventDispatcher:addEventListener(self)
    return self
end

--[[
    Creates a new encounter if a ENCOUNTER_START event occures.

    @param id EncounterId of the encounter started.
    @param name Name of the encounter that started.
    @param difficulty DifficultyId of the encounter started.
    @param raidSize Size of the raid when encounter has been pulled.
--]]
function SuuBossMods_EncounterHandler:ENCOUNTER_START(id, name, difficulty, raidSize)
    self.currentEncounter = SuuBossMods_Encounter(name, id, difficulty, raidSize)
    SuuBossMods.eventDispatcher:dispatchEvent("SUUBOSSMODS_ENCOUNTER_START", self.currentEncounter)
end

--[[
    Ends the currently active encounter if a ENCOUNTER_END event occures.

    @param result Result of the encounter.
--]]
function SuuBossMods_EncounterHandler:ENCOUNTER_END(_, _, _, _, result)
    if (self.currentEncounter ~= nil) then
        self.currentEncounter:endEncounter(result)
        table.insert(self.encounterHistory, self.currentEncounter)
    end
    SuuBossMods.eventDispatcher:dispatchEvent("SUUBOSSMODS_ENCOUNTER_END", self.currentEncounter)
    self.currentEncounter = nil
end

--[[
    Returns true if an encounter is currently running.

    @return Returns true if an encounter is running, false otherwise.
--]]
function SuuBossMods_EncounterHandler:isEncounterRunning()
    return self.currentEncounter ~= nil
end

--[[
    Returns information about the currently active encounter.

    @return Returns the currently active encounter. Nil of no encounter is active.
--]]
function SuuBossMods_EncounterHandler:getCurrentEncounter()
    return self.currentEncounter
end

--[[
	GameEvents EncounterHandler needs to handle.

	@return Game Events EncounterHandler needs to handle.
--]]
function SuuBossMods_EncounterHandler:getGameEvents()
    return {
        "ENCOUNTER_START",
        "ENCOUNTER_END"
    }
end