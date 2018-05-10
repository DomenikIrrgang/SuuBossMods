SuuBossMods_ModuleOption = CreateClass()

--[[
    Creates a new options entry for an options table in SuuBossMods.
--]]
function SuuBossMods_ModuleOption.new(name, description, type, get, set, source, setting1, setting2, setting3, setting4, setting5)
    local self = setmetatable({}, SuuBossMods_ModuleOption)
    self.name = name
    self.description = description
    self.get = get
    self.set = set
    self.source = source
    self.type = type
    self.setting1 = setting1
    self.setting2 = setting2
    self.setting3 = setting3
    self.setting4 = setting4
    self.setting5 = setting5
    return self
end

--[[
    Returns the name of the option.

    @return Name of the option.
--]]
function SuuBossMods_ModuleOption:getName()
    return self.name
end

function SuuBossMods_ModuleOption:setOption(info, value1, value2, value3, value4)
    self.set(self.source, value1, value2, value3, value4)
end

function SuuBossMods_ModuleOption:getOption(info)
    return self.get(self.source)
end

function SuuBossMods_ModuleOption:getOptionsTable()
    if self.type == "toggle" then
        return self:getToggleOption()
    elseif self.type == "range" then
        return self:getRangeOption()
    end
    return nil
end

function SuuBossMods_ModuleOption:getToggleOption()
    return {
        order = 1,
        type = "toggle",
        name = self.name,
        desc = self.description,
        set = "setOption",
        get = "getOption",
        handler = self,
    }
end

function SuuBossMods_ModuleOption:getRangeOption()
    return {
        order = 1,
        name = self.name,
        desc = self.description,
        type = "range",
        width = self.setting1,
        set = "setOption",
        get = "getOption",
        handler = self,
        min = self.setting2,
        max = self.setting3,
        step = self.setting4,
    }
end