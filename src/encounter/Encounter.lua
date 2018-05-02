SuuBossMods_Encounter = {}
SuuBossMods_Encounter.__index = SuuBossMods_Encounter

setmetatable(SuuBossMods_Encounter, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
    Creates a new Encounter.

    @param name Name of the Encounter.
    @param id EncounterId of the encounter.
    @param difficulty DifficultyId of the encounter.
    @param raidSize Size of the raid.
--]]
function SuuBossMods_Encounter.new(name, id, difficulty, raidSize)
    local self = setmetatable({}, SuuBossMods_Encounter)
    self.running = true
	self.pullTime = GetTime()
	self.endTime = GetTime()
	self.id = id
	self.difficulty = difficulty
    self.name = name
    self.raidSize = raidSize
    SuuBossMods:ChatMessage(encounterName .. " has been pulled. Good luck!")
    return self
end

--[[
    Returns the duration of the encounter.

    @return Duration of the encounter.
--]]
function SuuBossMods_Encounter:getDuration()
    return self.endTime - self.startTime
end

--[[
    Returns true if the encounter is on Mythic difficutly.

    @return True if encounter is Mythic difficulty.
--]]
function SuuBossMods_Encounter:IsMythic()
	return self.difficulty == 16
end

--[[
    Returns true if the encounter is on Heroic difficutly.

    @return True if encounter is Heroic difficulty.
--]]
function SuuBossMods_Encounter:IsHeroic()
	return self.difficulty == 15
end

--[[
    Returns true if the encounter is on Normal difficutly.

    @return True if encounter is Normal difficulty.
--]]
function SuuBossMods_Encounter:IsNormal()
	return self.difficulty == 14
end

--[[
    Ends the this encounter and measure the time and result.

    @param result 1 if encounter was successful.
--]]
function SuuBossMods_Encounter:endEncounter(result)
    self.endTime = GetTime()
    self.running = false
    self.result = result
    if (self.result == 1) then
        SuuBossMods:ChatMessage("Encounter against " .. self.name .. " (Success) has ended.")
    else
        SuuBossMods:ChatMessage("Encounter against " .. self.name .. " (Wipe) has ended.")
    end
end