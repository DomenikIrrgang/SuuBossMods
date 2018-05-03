SuuBossMods_DungeonModule = CreateClass()
local moduleCount = 0

function SuuBossMods_DungeonModule.new(name, uiMapId)
    local self = setmetatable({}, SuuBossMods_DungeonModule)
    self.name = name
    self.uiMapId = uiMapId
    self.moduleId = moduleCount
    moduleCount = moduleCount + 1
    self.encounterModules = {}
    self.gameEvents = {}
    self.customEvents = {}
    return self
end

function SuuBossMods_DungeonModule:getName()
    return self.name
end

function SuuBossMods_DungeonModule:init()
end

function SuuBossMods_DungeonModule:newModule(encounterName, encounterId)
    local newModule = SuuBossMods_EncounterModule(encounterName, encounterId)
    table.insert(self.encounterModules, newModule)
    return newModule
end

function SuuBossMods_DungeonModule:getEncounterModules()
    return self.encounterModules
end

function SuuBossMods_DungeonModule:getOptionsTable()
    local moduleOptions = {
        name = self.name,
        type = "group",
        order = self.moduleId,
        childGroups = "select",
        args = {
            intro = {
                order = 1,
                type = "description",
                name = "Change settings of an encounter .",
            },
        },
    }
    for key, encounterModule in pairs(self:getEncounterModules()) do
		moduleOptions.args[encounterModule:getName()] = encounterModule:getOptionsTable()
	end
	return moduleOptions
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