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

function SuuBossMods_EncounterModuleLoader:unloadModule()
    if (self.activeModule ~= nil) then
        self.activeModule:unload()
        self.eventDispatcher:clear()
    end
end

function SuuBossMods_EncounterModuleLoader:loadModule(encounter)
    for key, module in pairs(self.modules) do
        print(module.encounterId, encounter.id)
        if (module.encounterId == encounter.id) then
            self.activeModule = module
            self.activeModule:init()
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