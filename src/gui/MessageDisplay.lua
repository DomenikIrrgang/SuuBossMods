SuuBossMods_MessageDisplay = CreateClass()

function SuuBossMods_MessageDisplay.new()
    local self = setmetatable({}, SuuBossMods_MessageDisplay)
    self.messages = {}
    SuuBossMods.eventDispatcher:addEventListener(self)
    self.display = SuuBossMods_TextMessage("", 0, 0, 16)
    self.messagesCreated = 0
    self.messages = {}
    self.update = true
    self.lastUpdate = GetTime()
    self.frame = SbmGameApi.CreateFrame("Frame", "SuuBossMods_MessageDisplay")
    self.frame:SetScript("OnUpdate", function(_, renderTime)
        if (GetTime() - self.lastUpdate > self:getSettings().updateInterval) then
            self:updateMessages()
            self:updateDisplay()
        end
    end)
    return self
end

function SuuBossMods_MessageDisplay:getCustomEvents()
    return {
        "PROFILE_INIT",
        "PROFILE_CHANGED"
    }
end

function SuuBossMods_MessageDisplay:showMessage(message, duration)
    self.messagesCreated = self.messagesCreated + 1
    table.insert(self.messages, { ["id"] = self.messagesCreated, ["text"] = message, ["start"] = GetTime(), ["duration"] = duration})
end

function SuuBossMods_MessageDisplay:showMessageWithoutDuration(message)
    self.messagesCreated = self.messagesCreated + 1
    table.insert(self.messages, { ["id"] = self.messagesCreated, ["text"] = message, ["start"] = GetTime()})
    return self.messagesCreated
end

function SuuBossMods_MessageDisplay:removeMessage(messageId) 
    for key, message in pairs(self.messages) do
        if (message.id == messageId) then
            table.remove(self.messages, key)
        end
    end
end

function SuuBossMods_MessageDisplay:updateMessages()
    local i = 1
    while i <= table.getn(self.messages) do
        local message = self.messages[i]
        if (message.duration ~= nil and message.duration < GetTime() - message.start) then
            table.remove(self.messages, i)
            i = i -1
        end
        i = i + 1
    end
end

function SuuBossMods_MessageDisplay:updateDisplay()
    if (self.update == true) then
        local displayText = ""
        for key, message in pairs(self.messages) do
            displayText = displayText .. message.text .. "\n"
        end
        self.display:setText(displayText)
    end
end 

function SuuBossMods_MessageDisplay:init()
    self.display:setPosition(self:getSettings().x, self:getSettings().y)
    self.display:setFontSize(self:getSettings().size)
    self.display:setFontColor(self:getSettings().fontColor)
end

function SuuBossMods_MessageDisplay:PROFILE_INIT()
    self:init()
end

function SuuBossMods_MessageDisplay:PROFILE_CHANGED()
    self:init()
end

function SuuBossMods_MessageDisplay:getSettings()
    return SuuBossMods.profileHandler:getProfile().messageDisplay
end

function SuuBossMods_MessageDisplay:setSize(size)
    self.getSettings().size = size
    self.display:setFontSize(size)
end

function SuuBossMods_MessageDisplay:getSize()
    return self:getSettings().size
end

function SuuBossMods_MessageDisplay:setFontColor(color) 
    self:getSettings().fontColor = color
    self.display:setFontColor(color)
end

function SuuBossMods_MessageDisplay:getFontColor() 
    return self:getSettings().fontColor
end

function SuuBossMods_MessageDisplay:getUpdateInterval()
    return self:getSettings().updateInterval
end

function SuuBossMods_MessageDisplay:setUpdateInterval(updateInterval) 
    self:getSettings().updateInterval = updateInterval
end

function SuuBossMods_MessageDisplay:toggleAnchor()
    self.display:setLocked(not self.display:isLocked())
    self.update = self.display:isLocked()
    if (not self.display:isLocked()) then
        self.display:setText("MOVE ME")
    else
        self:getSettings().x = self.display:getX()
        self.getSettings().y = self.display:getY()
        self.display:setText("")
    end
end

function SuuBossMods_MessageDisplay:getDefaultSettings() 
    return {
        x = 811,
        y = 307,
        fontColor = {['r'] = 1, ['g'] = 0.2, ['b'] = 0.2, ['a'] = 1},
        size = 26,
        updateInterval = 0.1,
    }
end

function SuuBossMods_MessageDisplay:getOptionsTable()
    return {
        name = "MessageDisplay",
        type = "group",
        order = 1,
        childGroups = "select",
        args = {
            intro = {
                order = 1,
                type = "description",
                name = "Change MessageDisplay settings.",
            },
            toggle = {
                order = 2,
                type = "execute",
                name = "Toggle Anchor",
                desc = "Toggle MessageDisplay Anchor",
                func = function() 
                    SuuBossMods.messageDisplay:toggleAnchor()
                end,
            },
            general = {
                order = 3,
                type = "group",
                name = "General",
                args = {
                    updateInterval = {
                        order = 1,
                        name = "Message Update Frequency",
                        desc = "Sets the rate at which the messages get updated.",
                        type = "range",
                        width = "full",
                        get = function(info)
                            return SuuBossMods.messageDisplay:getUpdateInterval() end,
                        set = function(info, value) SuuBossMods.messageDisplay:setUpdateInterval(value) end,
                        min = 0.01, max = 1, step=0.01,
                    },
                    size = {
                        order = 2,
                        name = "Font Size",
                        desc = "Sets the font size of the display.",
                        type = "range",
                        width = "full",
                        get = function(info) return SuuBossMods.messageDisplay:getSize() end,
                        set = function(info, value) 
                            SuuBossMods.messageDisplay:setSize(value)
                        end,
                        min = 15, max = 32, step=1,
                    },
                    fontColor = {
                        order = 4,
                        name = "Font Color",
                        desc = "Sets the font color.",
                        type = "color",
                        hasAlpha = true,
                        get = function(info) return SuuBossMods.messageDisplay:getFontColor().r,
                            SuuBossMods.messageDisplay:getFontColor().g,
                            SuuBossMods.messageDisplay:getFontColor().b,
                            SuuBossMods.messageDisplay:getFontColor().a
                        end,
                        set = function(info, r, g, b, a) 
                            local color = {}
                            color.r = r
                            color.g = g
                            color.b = b
                            color.a = a
                            SuuBossMods.messageDisplay:setFontColor(color)
                        end,
                    },
                }	
            },
        }
    }
end