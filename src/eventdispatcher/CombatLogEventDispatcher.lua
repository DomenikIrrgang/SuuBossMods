SuuBossMods_CombatLogEventDispatcher = CreateClass()

function SuuBossMods_CombatLogEventDispatcher.new()
    local self = setmetatable({}, SuuBossMods_CombatLogEventDispatcher)
    self.eventDispatcher = SuuBossMods_EventDispatcher()
    self.events = {}
    self.enabled = false
    SuuBossMods.eventDispatcher:addEventListener(self)
    return self
end

function SuuBossMods_CombatLogEventDispatcher:getGameEvents()
    return {
        "COMBAT_LOG_EVENT_UNFILTERED",
    }
end

function SuuBossMods_CombatLogEventDispatcher:addEventCallback(eventName, spellId, callback, source)
    if (self.events[eventName] == nil) then
        self.events[eventName] = {}
    end
    local eventCallback = {}
    eventCallback.callback = callback
    eventCallback.spellId = spellId
    eventCallback.source = source
    table.insert(self.events[eventName], eventCallback)
end

function SuuBossMods_CombatLogEventDispatcher:isEnabled()
    return self.enabled
end

function SuuBossMods_CombatLogEventDispatcher:setEnabled(enabled)
    self.enabled = enabled
end

function SuuBossMods_CombatLogEventDispatcher:clear()
    self.events = {}
end

function SuuBossMods_CombatLogEventDispatcher:COMBAT_LOG_EVENT_UNFILTERED()
    local _, event, _, sourceGuid, sourceName, sourceFlags, sourceFlags2, destGuid, destName, destFlags, destFlags2, spellId, spellName, spellSchool, auraType, amount= CombatLogGetCurrentEventInfo()
	local combatLogEvent = {}
	combatLogEvent.event = event
	combatLogEvent.sourceGuid = sourceGuid
	combatLogEvent.sourceName = sourceName
	combatLogEvent.destGuid = destGuid
	combatLogEvent.destName = destName
    combatLogEvent.spellId = spellId
    combatLogEvent.spellName = spellName
    combatLogEvent.spellSchool = spellSchool
    combatLogEvent.auraType = auraType
    combatLogEvent.amount = amount

    local guidValues = {}
	local i = 1
    for word in string.gmatch(combatLogEvent.sourceGuid, '([^-]+)') do
        guidValues[i] = word
        i = i + 1
    end
    combatLogEvent.unitId = guidValues[6]

    if (self.events[combatLogEvent.event] ~= nil) then
        for i, eventListener in ipairs(self.events[combatLogEvent.event]) do
            if ((eventListener.spellId == spellId or eventListener.spellId == nil) and event ~= "UNIT_DIED") then
                local guidValues = {}
                local j = 1
                            
                for word in string.gmatch(sourceGuid, '([^-]+)') do
                    guidValues[j] = word
                    j = j + 1
                end
                if (guidValues[1] == "Creature") then
                    combatLogEvent.npc = guidValues[6]
                end
                eventListener.callback(eventListener.source, combatLogEvent)
            end
            
            if (event == "UNIT_DIED" and eventListener.event == "UNIT_DIED") then
                local guidValues = {}
                local j = 1
                            
                for word in string.gmatch(destGuid, '([^-]+)') do
                    guidValues[j] = word
                    j = j + 1
                end
    
                if (eventListener.spellId == tonumber(guidValues[6])) then
                    self[k.callback](self, combatLogEvent)
                end
            end
        end
    end
end

function SuuBossMods_CombatLogEventDispatcher:bindSpellCastStart(spellId, callback) 
    self:addEventCallback("SPELL_CAST_START", function(...)
        
    end)
end

