SuuBossMods_ProfileHandler = {}
SuuBossMods_ProfileHandler.__index = SuuBossMods_ProfileHandler

setmetatable(SuuBossMods_ProfileHandler, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function SuuBossMods_ProfileHandler.new(_, name)
    local self = setmetatable({}, SuuBossMods_ProfileHandler)
    SuuBossMods.eventDispatcher:addEventListener(self)
    return self
end

function SuuBossMods_ProfileHandler:initDefaultValues()
    self.defaults = {
        profile = {
            modules = {
                ['*'] = {
                    enabled = true,
                    locked = true,
                    visible = true,
                },
            },
            plugins = {
                ['*'] = {
                    enabled = true,
                },
            },
            messageDisplay = SuuBossMods.messageDisplay:getDefaultSettings(),
        }
    }
end

function SuuBossMods_ProfileHandler:ProfileChanged()
    SuuBossMods.eventDispatcher:dispatchEvent("PROFILE_CHANGED")
end

function SuuBossMods_ProfileHandler:getDefaults()
    return self.defaults
end

function SuuBossMods_ProfileHandler:SUUBOSSMODS_INIT()
    self:initDefaultValues()
    self.db = LibStub("AceDB-3.0"):New("SuuBossModsDB", self.defaults)
    self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
    SuuBossMods.eventDispatcher:dispatchEvent("PROFILE_INIT")
end

function SuuBossMods_ProfileHandler:getProfile() 
    return self.db.profile
end

function SuuBossMods_ProfileHandler:getCustomEvents()
    return {
        "SUUBOSSMODS_INIT"
    }
end