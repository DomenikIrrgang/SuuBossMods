SuuBossMods_DungeonModuleLoader = CreateClass()

function SuuBossMods_DungeonModuleLoader.new()
    local self = setmetatable({}, SuuBossMods_DungeonModuleLoader)
    self.modules = {}
    self.activeModule = nil
    self.eventDispatcher = SuuBossMods_EventDispatcher()
    SuuBossMods.eventDispatcher:addEventListener(self)
    return self
end

function SuuBossMods_DungeonModuleLoader:newModule(moduleName, uiMapId)
    local newModule = SuuBossMods_DungeonModule(moduleName, uiMapId)
    table.insert(self.modules, newModule)
    return newModule
end

function SuuBossMods_DungeonModuleLoader:getModules()
    return self.modules
end

function SuuBossMods_DungeonModuleLoader:getCustomEvents()
    return {
        "DUNGEON_ENTERED",
        "DUNGEON_EXITED"
    }
end

function SuuBossMods_DungeonModuleLoader:DUNGEON_ENTERED(dungeon)
    self:loadModule(dungeon)
end

function SuuBossMods_DungeonModuleLoader:DUNGEON_EXITED(dungeon)
    self:unloadModule(dungeon)
end

function SuuBossMods_DungeonModuleLoader:unloadModule()
    if (self.activeModule ~= nil) then
        self.activeModule:unload()
        self.activeModule.combatLogEventDispatcher:setEnabled(false)
        self.activeModule.combatLogEventDispatcher:clear()
        self.eventDispatcher:clear()
        SuuBossMods.eventDispatcher:dispatchEvent("DUNGEONMODULE_UNLOADED", self.activeModule)
        self.activeModule = nil
    end
end

function SuuBossMods_DungeonModuleLoader:loadModule(dungeon)
    for key, module in pairs(self.modules) do
        if (module.uiMapId == dungeon.uiMapId) then
            self.activeModule = module
            self.activeModule:loadDefaultSettings()
            self.activeModule:init()
            self.activeModule.combatLogEventDispatcher:setEnabled(true)
            self.eventDispatcher:addEventListener(self.activeModule)
            SuuBossMods.eventDispatcher:dispatchEvent("DUNGEONMODULE_LOADED", self.activeModule)
            return
        end
    end
    SuuBossMods:chatMessage("No module found for dungeon!")
end

function SuuBossMods_DungeonModuleLoader:hasActiveModule()
    return self.activeModule ~= nil
end

function SuuBossMods_DungeonModuleLoader:getActiveModule()
    return self.activeModule
end