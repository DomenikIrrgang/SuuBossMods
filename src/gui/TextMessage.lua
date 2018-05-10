SuuBossMods_TextMessage = CreateClass()
local text_counter = 0

function SuuBossMods_TextMessage.new(text, x, y, size)
	local self = setmetatable({}, SuuBossMods_TextMessage)
	self.frame = CreateFrame("Frame", "SuuBossMods_TextMessage" .. text_counter, UIParent)
	self.x = x
	self.y = y
	self.size = size
	self.text = text
	self.visible = false
	self.locked = true
	self.frame:SetPoint("TOPLEFT",UIParent, self.x, -self.y)
	self.frame:SetSize(300, 50)
	self.text_frame = self.frame:CreateFontString("Text", "OVERLAY")
	self.text_frame:SetPoint("CENTER",self.frame, 0, 0)
	self.text_frame:SetFont("Fonts\\FRIZQT__.TTF", self.size, "OUTLINE")
	self.text_frame:SetTextColor(1, 0.2, 0.2,1)
	self.text_frame:SetText(self.text)
	self.text_frame:SetShadowOffset(1, -1)
	
	self.frame:SetScript("OnMouseDown", function()
		if (self.locked ~= true) then
			self.frame:SetMovable(true)
			self.frame:StartMoving(self.frame)
		end
	end)

	self.frame:SetScript("OnMouseUp", function()
		self.frame:StopMovingOrSizing()
		self.frame:SetMovable(false)
		self.x = self.frame:GetLeft()
		self.y = (GetScreenHeight() -self.frame:GetTop())
	end)
    self.frame:EnableMouse(false)
	return self
end

function SuuBossMods_TextMessage:isLocked()
	return self.locked
end

function SuuBossMods_TextMessage:hide()
	self.visible = false
	self.frame:Hide()
end

function SuuBossMods_TextMessage:show()
	self.visible = true
	self.frame:show()
end

function SuuBossMods_TextMessage:setVisible(visible)
	if (visible) then
		self:show()
	else
		self:hide()
	end
end

function SuuBossMods_TextMessage:getX()
    return self.x
end

function SuuBossMods_TextMessage:getY()
    return self.y
end

function SuuBossMods_TextMessage:isVisible()
	return self.visible
end

function SuuBossMods_TextMessage:setText(text)
	self.text = text
	self.text_frame:SetText(self.text)
end

function SuuBossMods_TextMessage:setFontSize(size)
	self.size = size
	self.text_frame:SetFont("Fonts\\FRIZQT__.TTF", self.size, "OUTLINE")
end

function SuuBossMods_TextMessage:setFontColor(color)
	self.text_frame:SetTextColor(color.r, color.g, color.b, color.a)
end

function SuuBossMods_TextMessage:setLocked(locked)
	self.locked = locked
	self.frame:EnableMouse(not locked)
end

function SuuBossMods_TextMessage:setPosition(x, y)
	self.x = x
	self.y = y
	self.frame:SetPoint("TOPLEFT",UIParent, self.x, -self.y)
	self.text_frame:SetPoint("CENTER",self.frame, 0, 0)
end