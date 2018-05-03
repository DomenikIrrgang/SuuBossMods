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
    self.gameEvents = {}
    self.frame = SbmGameApi.CreateFrame("Frame", "SuuBossMods_EventDispatcher")
    self.frame:SetScript("OnEvent", function(_, event, ...)
      self:dispatchEvent(event, ...)
    end)
    return self
end

--[[
  Removes all listener of the dispatcher
--]]
function SuuBossMods_EventDispatcher:clear()
  self.listener = {}
  for event, value in pairs(self.gameEvents) do
    self.frame:UnregisterEvent(event)
  end
end

--[[
  Adds a new Eventlistener. Uses the getGameEvents() and getCustomEvents() function of the listener to get the events
  the listener wants to listen to.

  @param eventListener EventListener to be added.
--]]
function SuuBossMods_EventDispatcher:addEventListener(eventListener)
  self:addGameEventListener(eventListener)
  self:addCustomEventListener(eventListener)
end

--[[
  Adds a new Eventlistener. Uses the getGameEvents() function of the listener to get the events
  the listener wants to listen to.

  @param eventListener EventListener to be added.
--]]
function SuuBossMods_EventDispatcher:addGameEventListener(eventListener)
  if (eventListener.getGameEvents ~= nil) then
    for key, event in pairs(eventListener:getGameEvents()) do
      self:addEventIfNotExist(event)
      if (self.listener[eventvalue] == nil) then
        self.listener[event] = {}
        self.gameEvents[event] = true
      end
      table.insert(self.listener[event], eventListener)
    end
  end
end

--[[
  Adds a new Eventlistener. Uses the getCustomEvents() function of the listener to get the events
  the listener wants to listen to.

  @param eventListener EventListener to be added.
--]]
function SuuBossMods_EventDispatcher:addCustomEventListener(eventListener)
  if (eventListener.getCustomEvents ~= nil) then
    for key, event in pairs(eventListener:getCustomEvents()) do
      if (self.listener[event] == nil) then
        self.listener[event] = {}
      end
      table.insert(self.listener[event], eventListener)
    end
  end
end

--[[
  Registers an event if it has not been registered yet.

  @param eventListener EventListener to be added.
--]]
function SuuBossMods_EventDispatcher:addEventIfNotExist(event) 
  if (self.frame:IsEventRegistered(event) ~= nil) then
    self.frame:RegisterEvent(event)
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
    for key, listener in pairs(self.listener[event]) do
      if (listener["isEnabled"] == nil or (listener["isEnabled"] ~= nil and listener:isEnabled())) then
        listener[event](listener, ...)
      end
    end
  end
end