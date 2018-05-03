SuuBossMods_Dungeon = CreateClass()

function SuuBossMods_Dungeon.new(name, difficultyId, difficultyName, uiMapId)
    local self = setmetatable({}, SuuBossMods_Dungeon)
    self.name = name
    self.difficultyId = difficultyId
    self.difficultyName = difficultyName
    self.uiMapId = uiMapId
    return self
end