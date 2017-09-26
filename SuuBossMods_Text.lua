SBM_Text = {}
SBM_Text.__index = SBM_Text

setmetatable(SBM_Text, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local text_counter = 0

function SBM_Text.new(text, x, y, size)
	local self = setmetatable({}, SBM_Text)
	self.frame = CreateFrame("Frame", "SBM_Text" .. text_counter, UIParent)
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

function SBM_Text:IsLocked()
	return self.locked
end

function SBM_Text:Hide()
	self.visible = false
	self.frame:Hide()
end

function SBM_Text:Show()
	self.visible = true
	self.frame:Show()
end

function SBM_Text:SetVisible(visible)
	if (visible) then
		self:Show()
	else
		self:Hide()
	end
end

function SBM_Text:IsVisible()
	return self.visible
end

function SBM_Text:SetText(text)
	self.text = text
	self.text_frame:SetText(self.text)
end

function SBM_Text:SetFontSize(size)
	self.size = size
	self.text_frame:SetFont("Fonts\\FRIZQT__.TTF", self.size, "OUTLINE")
end

function SBM_Text:SetTextColor(color)
	self.text_frame:SetTextColor(color.r, color.g, color.b, color.a)
end

function SBM_Text:SetLocked(locked)
	self.locked = locked
	self.frame:EnableMouse(not locked)
end

function SBM_Text:SetPosition(x, y)
	self.x = x
	self.y = y
	self.frame:SetPoint("TOPLEFT",UIParent, self.x, -self.y)
	self.text_frame:SetPoint("CENTER",self.frame, 0, 0)
end