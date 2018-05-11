SuuBossMods_DungeonModule = CreateClass()
local moduleCount = 0

function SuuBossMods_DungeonModule.new(name, uiMapId)
    local self = setmetatable({}, SuuBossMods_DungeonModule)
    self.name = name
    self.uiMapId = uiMapId
    self.moduleId = moduleCount
    moduleCount = moduleCount + 1
    self.encounterModules = {}
    self.combatLogEventDispatcher = SuuBossMods_CombatLogEventDispatcher()
    self.gameEvents = {}
    self.customEvents = {}
    self.options = {}
    self.trashSpells = {}
    self.trash = {}
    return self
end

function SuuBossMods_DungeonModule:getName()
    return self.name
end

function SuuBossMods_DungeonModule:load()
    self:addEventCallback("SPELL_CAST_START", nil, self.collectInfo)
    self:addEventCallback("SPELL_INTERRUPT", nil, self.collectInfo)
end

function SuuBossMods_DungeonModule:unload()
end

function SuuBossMods_DungeonModule:newModule(encounterName, encounterId)
    local newModule = SuuBossMods_EncounterModule(encounterName, encounterId)
    table.insert(self.encounterModules, newModule)
    return newModule
end

function SuuBossMods_DungeonModule:addEventCallback(combatLogEvent, spellId, callback)
    self.combatLogEventDispatcher:addEventCallback(combatLogEvent, spellId, callback, self)
end

function SuuBossMods_DungeonModule:collectInfo(combatLogEvent)
    if (combatLogEvent.event == "SPELL_CAST_START") then
        if (self:getSettings().spellData[combatLogEvent.spellId] == nil and combatLogEvent.unitId ~= nil) then
            self:getSettings().spellData[combatLogEvent.spellId] = {}
            self:getSettings().spellData[combatLogEvent.spellId].name = combatLogEvent.spellName
            self:getSettings().spellData[combatLogEvent.spellId].units = {}
        end
        local unitIdFound = false
        for key, unit in pairs(self:getSettings().spellData[combatLogEvent.spellId].units) do
            if (unit.unitId == combatLogEvent.unitId or unit.name == combatLogEvent.sourceName) then
                unitIdFound = true
                break
            end
        end
        if (unitIdFound == false) then
            local unit = {}
            unit.unitId = combatLogEvent.unitId
            unit.name = combatLogEvent.sourceName
            table.insert(self:getSettings().spellData[combatLogEvent.spellId].units, unit)
        end
    end

    if (combatLogEvent.event == "SPELL_INTERRUPT") then
        self:getSettings().spellData[combatLogEvent.interuptedSpellId].interuptable = true
    end
end

function SuuBossMods_DungeonModule:printCollectedInfo()
    print("Spellinfo for: ", self.name)
    print("--------------------------------------------")
    for spellId, spellInfo in pairs(self:getSettings().spellData) do
        if (spellInfo.units[1].unitId ~= nil) then
            print("SpellId: ", spellId, " Spellname: ", spellInfo.name)
            print("Interupable: ", (spellInfo.interuptable or "Unknown"))
            print("Units that cast this spell:")
            for key, unit in pairs(spellInfo.units) do
                print("UnitId: ", unit.unitId, " Unitname: ", unit.name)
            end
            print("--------------------------------------------")
        end
    end
end

function SuuBossMods_DungeonModule:addTrashSpell(spellId, interuptable)
    local spellInfo = {}
    spellInfo.spellId = spellId
    spellInfo.interuptable = interuptable
    table.insert(self.trashSpells, spellInfo)
end

function SuuBossMods_DungeonModule:addUnit(unitId, stunable)
    local unitInfo = {}
    unitInfo.unitId = unitId
    unitInfo.stunable = stunable
    table.insert(self.trash, unitInfo)
end

function SuuBossMods_DungeonModule:getEncounterModules()
    return self.encounterModules
end

function SuuBossMods_DungeonModule:getSettings()
    return SuuBossMods.profileHandler:getProfile().modules[self.name]
end

function SuuBossMods_DungeonModule:addOption(name, description, type, get, set, setting1, setting2, setting3, setting4, setting5)
    table.insert(self.options, SuuBossMods_ModuleOption(name, description, type, get, set, self, setting1, setting2, setting3, setting4, setting5))
end

function SuuBossMods_DungeonModule:getOptionsTable()
    self:loadDefaultSettings()
    local moduleOptions = {
        name = self.name,
        type = "group",
        order = self.moduleId,
        childGroups = "select",
        args = {
            intro = {
                order = 1,
                type = "description",
                name = "Change settings of an encounter.",
            },
            spellInfo = {
                order = 2,
                type = "execute",
                name = "Print Spellinfo",
                desc = "Print all spell information collected in this dungeon.",
                func = "printCollectedInfo",
                handler = self,
            },
        },
    }
    moduleOptions.args["Trash"] = self:getTrashOptionsTable()
    for key, encounterModule in pairs(self:getEncounterModules()) do
		moduleOptions.args[encounterModule:getName()] = encounterModule:getOptionsTable()
    end
	return moduleOptions
end

function SuuBossMods_DungeonModule:getTrashOptionsTable()
    local trashOptions = {
		name = "Trash",
		type = "group",
        order = 1,
        args = {},
    }
    for key, option in pairs(self.options) do
        trashOptions.args[option:getName()] = option:getOptionsTable()
    end
    return trashOptions
end

function SuuBossMods_DungeonModule:getDefaultSettings()
    return {
        spellData = {},
    }
end

function SuuBossMods_DungeonModule:loadDefaultSettings()
    for key, value in pairs(self:getDefaultSettings()) do
        if (self:getSettings()[key] == nil) then
            self:getSettings()[key] = value
        end
    end
end

--[[
    Returns the events the module should react to. Override for 
    changing the events to react to.
--]]
function SuuBossMods_DungeonModule:getGameEvents()
    return self.gameEvents
end

--[[
    Returns the events the module should react to. Override for 
    changing the events to react to.
--]]
function SuuBossMods_DungeonModule:getCustomEvents()
    return self.customEvents
end

--[[
    Adds an event the module will react to.

    @param event Event that will be added.
--]]
function SuuBossMods_DungeonModule:addGameEvent(event)
    table.insert(self.gameEvents, event)
end

--[[
    Adds an event the module will react to.

    @param event Event that will be added.
--]]
function SuuBossMods_DungeonModule:addCustomEvent(event)
    table.insert(self.customEvents, event)
end