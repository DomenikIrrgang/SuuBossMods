SuuBossMods_EncounterModuleLoader = CreateClass()

function SuuBossMods_EncounterModuleLoader.new()
    local self = setmetatable({}, SuuBossMods_EncounterModuleLoader)
    self.modules = {}
    self.activeModule = nil
    self.eventDispatcher = SuuBossMods_EventDispatcher()
    SuuBossMods.eventDispatcher:addEventListener(self)
    return self
end

function SuuBossMods_EncounterModuleLoader:getCustomEvents()
    return {
        "SUUBOSSMODS_ENCOUNTER_START",
        "SUUBOSSMODS_ENCOUNTER_END",
        "DUNGEONMODULE_LOADED",
        "DUNGEONMODULE_UNLOADED",
    }
end

function SuuBossMods_EncounterModuleLoader:SUUBOSSMODS_ENCOUNTER_START(encounter)
    self:loadModule(encounter)
end

function SuuBossMods_EncounterModuleLoader:SUUBOSSMODS_ENCOUNTER_END()
    self:unloadModule()
end

function SuuBossMods_EncounterModuleLoader:DUNGEONMODULE_LOADED(dungeonModule)
    self.modules = dungeonModule:getEncounterModules()
end

function SuuBossMods_EncounterModuleLoader:DUNGEONMODULE_UNLOADED(dungeonModule)
    self:unloadModule()
    self.modules = {}
end

function SuuBossMods_EncounterModuleLoader:unloadModule()
    if (self.activeModule ~= nil) then
        self.activeModule:unload()
        self.activeModule.combatLogEventDispatcher:setEnabled(false)
        self.activeModule.combatLogEventDispatcher:clear()
        self.eventDispatcher:clear()
    end
end

function SuuBossMods_EncounterModuleLoader:loadModule(encounter)
    for key, module in pairs(self.modules) do
        if (module.encounterId == encounter.id) then
            self.activeModule = module
            self.activeModule:init()
            self.activeModule.combatLogEventDispatcher:setEnabled(true)
            self.eventDispatcher:addEventListener(self.activeModule)
            return
        end
    end
    SuuBossMods:chatMessage("No module found for this boss!")
end

function SuuBossMods_EncounterModuleLoader:hasActiveModule()
    return self.activeModule ~= nil
end

function SuuBossMods_EncounterModuleLoader:getActiveModule()
    return self.activeModule
end