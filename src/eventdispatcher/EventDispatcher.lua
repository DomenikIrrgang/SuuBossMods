SuuBossMods_EventDispatcher = {}
SuuBossMods_EventDispatcher.__index = SuuBossMods_EventDispatcher

setmetatable(SuuBossMods_EventDispatcher, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
  Creates a new Eventdispatcher.
--]]
function SuuBossMods_EventDispatcher.new()
    local self = setmetatable({}, SuuBossMods_EventDispatcher)
    self.listener = {}
    self.frame = CreateFrame("frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
      self:dispatchEvent(event, ...)
    end)
    return self
end

--[[
  Adds a new Eventlistener. Uses the getEvents() function of the listener to get the events
  the listener wants to listen to.

  @param eventListener EventListener to be added.
--]]
function SuuBossMods_EventDispatcher:addEventListener(eventListener)
  for key, value in pairs(eventListener:getEvents()) do
    if (self.listener[value] == nil) then
      self.listener[value] = {}
    end
    table.insert(self.listener[value], eventListener)
  end
end

--[[
  Calls all listeners for a given event and forwards the event arguments.
  Also check if a listener is enabled by calling isEnabled() before invoking
  the event function.

  @param event Event that will be dispatched.
  @param ... Arguments of the event.
--]]
function SuuBossMods_EventDispatcher:dispatchEvent(event, ...)
  if self.listener[event] ~= nil then
    for key, value in pairs(self.listener[event]) do
      if (value[event]["isEnabled"] ~= nil or (value[event]["isEnabled"] and value[event]:isEnabled())) then
        value[event](value, ...)
      end
    end
  end
end