CoreEventListener = {}
CoreEventListener.__index = CoreEventListener

setmetatable(CoreEventListener, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
  Creates a new CoreEventListener.
--]]
function EventDispatcher.new()
    local self = setmetatable({}, EventDispatcher)
    return self
end

function CoreEventListener:getEvents() 
    return {
        "COMBAT_LOG_EVENT_UNFILTERED",
        "ENCOUNTER_START",
        "ENCOUNTER_END",
        "CHAT_MSG_ADDON",
        "PLAYER_REGEN_ENABLED",
        "PLAYER_REGEN_DISABLED",
        "UNIT_POWER_FREQUENT",
        "UNIT_SPELLCAST_SUCCEEDED",
    }
end