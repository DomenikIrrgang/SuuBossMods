local bar_counter = 0

EventDispatcher = {}
EventDispatcher.__index = EventDispatcher

setmetatable(EventDispatcher, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
  Creates a new Eventdispatcher.
--]]
function EventDispatcher.new()
    local self = setmetatable({}, EventDispatcher)
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
function EventDispatcher:addEventListener(eventListener)
  for key, value in pairs(eventListener:getEvents()) do
    if (self.listener[value] == nil) then
      self.listener[value] = {}
    end
    table.insert(self.listener[value], eventListener)
  end
end

--[[
  Calls all listeners for a given event and forwards the event arguments.

  @param event Event that will be dispatched.
  @param ... Arguments of the event.
--]]
function EventDispatcher:dispatchEvent(event, ...)
  if self.listener[event] ~= nil then
    for key, value in pairs(self.listener[event]) do
      value[event](value, ...)
    end
  end
end