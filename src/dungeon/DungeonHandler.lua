SuuBossMods_DungeonHandler = CreateClass()

function SuuBossMods_DungeonHandler.new()
    local self = setmetatable({}, SuuBossMods_DungeonHandler)
    self.currentDungeon = nil
    SuuBossMods.eventDispatcher:addEventListener(self)
    return self
end

function SuuBossMods_DungeonHandler:getGameEvents()
    return {
        "PLAYER_ENTERING_WORLD",
    }
end

function SuuBossMods_DungeonHandler:PLAYER_ENTERING_WORLD()
    if (self:isInDungeon()) then
        self:startNewDungeon()
    else
        if (self:dungeonActive()) then
            self:stopCurrentDungeon()
        end
    end
end

function SuuBossMods_DungeonHandler:dungeonActive()
    return self.currentDungeon ~= nil
end

function SuuBossMods_DungeonHandler:isInDungeon()
    local _, instanceType = GetInstanceInfo()
    return instanceType ~= "none"
end

function SuuBossMods_DungeonHandler:getCurrentDungeon()
    return self.currentDungeon
end

function SuuBossMods_DungeonHandler:stopCurrentDungeon()
    SuuBossMods.eventDispatcher:dispatchEvent("DUNGEON_EXITED", self.currentDungeon)
    self.currentDungeon = nil    
end

function SuuBossMods_DungeonHandler:startNewDungeon()
    local name, _, difficultyId, difficultyName, _, _, _, instanceMapID = GetInstanceInfo()
    local uiMapId = C_Map.GetBestMapForUnit("player")
    if (self:dungeonActive() and self.currentDungeon.uiMapId ~= uiMapId) then
        self:stopCurrentDungeon()
    end
    self.currentDungeon = SuuBossMods_Dungeon(name, difficultyId, difficultyName, instanceMapID)
    print(uiMapId)
    SuuBossMods:chatMessage("Entered Dungeon: " .. self.currentDungeon.name .. " (" .. self.currentDungeon.uiMapId .. ")")
    SuuBossMods.eventDispatcher:dispatchEvent("DUNGEON_ENTERED", self.currentDungeon)
end