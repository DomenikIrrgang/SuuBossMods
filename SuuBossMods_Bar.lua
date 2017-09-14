local bar_counter = 0

SBM_Bar = {}
SBM_Bar.__index = SBM_Bar

setmetatable(SBM_Bar, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function SBM_Bar.new(x, y, width, height, current_value, maximum_value)
  local self = setmetatable({}, SBM_Bar)
  bar_counter = bar_counter + 1
	self.spellID = 107
	self.width = width
	self.height = height
	self.x = x;
	self.y = y;
	self.locked = true
	self.LongTimerFrame = CreateFrame("Frame", "SBM_Bar" .. bar_counter, UIParent)
	self.LongTimerFrame:SetSize(width + 3, height + 6)
	self.LongTimerFrame:SetPoint("TOPLEFT", UIParent, x, -y)

	self.LongTimerFrame:SetBackdrop({
		bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3, },
	})
	
	self.LongTimerFrame:SetBackdropColor(112/255, 154/255, 255/255,0.5)
	self.LongTimerFrame:SetBackdropBorderColor(0,0,0,1)

	
	local icon_height = height - 2
	local icon_width = icon_height
	self.LongTimerFrame.IconFrame = CreateFrame("Frame", nil, self.LongTimerFrame)
	self.LongTimerFrame.IconFrame:SetSize(icon_width, icon_height)
	self.LongTimerFrame.IconFrame:SetPoint("LEFT", self.LongTimerFrame)

	self.LongTimerFrame.BarFrame = CreateFrame("Frame", nil, self.LongTimerFrame)
	self.LongTimerFrame.BarFrame:SetSize(width - icon_width - 5, height)
	self.LongTimerFrame.BarFrame:SetPoint("TOPLEFT", 0,0)

	self.LongTimerFrame.IconFrame.texture = self.LongTimerFrame.IconFrame:CreateTexture()
	self.LongTimerFrame.IconFrame.texture:SetPoint("TOPLEFT", 4, 1)
	self.LongTimerFrame.IconFrame.texture:SetPoint("TOPRIGHT", 4, 1)
	self.LongTimerFrame.IconFrame.texture:SetPoint("BOTTOMLEFT", 4, -1)
	--LongTimerFrame.IconFrame.texture:SetPoint("BOTTOMRIGHT", 1, -1)
	self.LongTimerFrame.IconFrame.texture:SetTexture(GetSpellTexture(self.spellID))

	self.MyStatusBar = CreateFrame("StatusBar", nil, self.LongTimerFrame.BarFrame)
	self.MyStatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	self.MyStatusBar:GetStatusBarTexture():SetHorizTile(false)
	self.MyStatusBar:SetMinMaxValues(0, maximum_value)
	self.MyStatusBar:SetValue(current_value)
	self.MyStatusBar:SetWidth(20)
	self.MyStatusBar:SetHeight(height)
	self.MyStatusBar:SetPoint("TOPLEFT", icon_width + 5, -3)
	self.MyStatusBar:SetPoint("TOPRIGHT", icon_width + 5, -3)
	self.MyStatusBar:SetStatusBarColor(0,59/255,207/255,0.7)
	
	self.MyStatusBar.bg = self.MyStatusBar:CreateTexture(nil, "BACKGROUND")
	self.MyStatusBar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
	self.MyStatusBar.bg:SetAllPoints(true)
	self.MyStatusBar.bg:SetVertexColor(112/255, 154/255, 255/255,0)
	
	self.MyStatusBar.timerduration = self.MyStatusBar:CreateFontString(nil, "OVERLAY")
	self.MyStatusBar.timerduration:SetPoint("RIGHT", self.MyStatusBar, "RIGHT", 0, 0)
	self.MyStatusBar.timerduration:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	self.MyStatusBar.timerduration:SetJustifyH("RIGHT")
	self.MyStatusBar.timerduration:SetShadowOffset(1, -1)
	self.MyStatusBar.timerduration:SetTextColor(1, 1, 1)
	self.MyStatusBar.timerduration:SetText("5.6s")
	
	self.MyStatusBar.timername = self.MyStatusBar:CreateFontString("TimerName", "OVERLAY")
	self.MyStatusBar.timername:SetPoint("LEFT", self.MyStatusBar, "LEFT", 4, 0)
	self.MyStatusBar.timername:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	self.MyStatusBar.timername:SetJustifyH("RIGHT")
	self.MyStatusBar.timername:SetShadowOffset(1, -1)
	self.MyStatusBar.timername:SetTextColor(1, 1, 1)
	self.MyStatusBar.timername:SetText("Leg Sweep")
	
	self.LongTimerFrame:SetScript("OnMouseDown", function()
		if (self.locked ~= true) then
			self.LongTimerFrame:SetMovable(true)
			self.LongTimerFrame:StartMoving(self.LongTimerFrame)
		end
	end)

	self.LongTimerFrame:SetScript("OnMouseUp", function()
		self.LongTimerFrame:StopMovingOrSizing()
		self.LongTimerFrame:SetMovable(false)
		self.x = self.LongTimerFrame:GetLeft()
		self.y = (GetScreenHeight() -self.LongTimerFrame:GetTop())
	end)
  return self
end

function SBM_Bar:SetWidth(width)
	self.width = width
	local icon_height = self.height - 2
	local icon_width = icon_height
	self.LongTimerFrame:SetSize(width + 3, self.height + 6)
	self.LongTimerFrame.IconFrame:SetSize(icon_width, icon_height)
	self.LongTimerFrame.BarFrame:SetSize(width - icon_width - 5, self.height)
end

function SBM_Bar:SetCurrentValue(current_value)
	self.MyStatusBar:SetValue(current_value)
end

function SBM_Bar:GetCurrentValue()
	return self.MyStatusBar:GetValue()
end

function SBM_Bar:SetMaximumValue(maximum_value)
	self.MyStatusBar:SetMinMaxValues(0, maximum_value)
end

function SBM_Bar:SetTimerName(timer_name)
	self.MyStatusBar.timername:SetText(timer_name)
end

function SBM_Bar:SetTimerDuration(timer_duration)

	if (timer_duration == "") then
		self.MyStatusBar.timerduration:SetText("")
	else
		local appendix_s = "s"
		local appendix_m = "m"
		if (timer_duration/60 >= 1) then
			local seconds = (timer_duration % 60) - ((timer_duration % 60) % 1)
			local minutes = (timer_duration - timer_duration % 60) / 60
			seconds = ("%.0f"):format(seconds)
			local seconds_length = string.len(seconds)
			if (seconds_length > 1) then
				self.MyStatusBar.timerduration:SetText(minutes .. ":" .. seconds)
			else
				self.MyStatusBar.timerduration:SetText(minutes .. ":0" .. seconds)
			end
		else
			local seconds = timer_duration % 60
			if (seconds <= SuuBossMods.db.profile.soonbar.threshold) then
				self.MyStatusBar.timerduration:SetText(seconds)
			else
				self.MyStatusBar.timerduration:SetText(("%.0f"):format(seconds))
			end
			
		end	
	end
end

function SBM_Bar:SetBarColor(r, g, b, a)
	self.MyStatusBar:SetStatusBarColor(r,g,b,a)
end

function SBM_Bar:SetBackgroundColor(r, g, b, a)
	self.LongTimerFrame:SetBackdropColor(r,g,b,a)
end

function SBM_Bar:SetSpellID(spellID)
	self.spellID = spellID
	self.LongTimerFrame.IconFrame.texture:SetTexture(GetSpellTexture(self.spellID))
end

function SBM_Bar:SetHeight(height)
	self.height = height
	local icon_height = height - 2
	local icon_width = icon_height
	self.LongTimerFrame:SetSize(self.width + 3, self.height + 6)
	self.LongTimerFrame.IconFrame:SetSize(icon_width, icon_height)
	self.LongTimerFrame.BarFrame:SetSize(self.width - icon_width - 5, self.height)
	self.MyStatusBar:SetHeight(height)
	self.MyStatusBar:SetPoint("TOPLEFT", icon_width + 5, -3)
	self.MyStatusBar:SetPoint("TOPRIGHT", icon_width + 5, -3)
end

function SBM_Bar:SetX(x)
	self.x = x
	self.LongTimerFrame:SetPoint("TOPLEFT", UIParent, x, -self.y)
end

function SBM_Bar:SetY(y)
	self.y = y
	self.LongTimerFrame:SetPoint("TOPLEFT", UIParent, self.x, -y)
end

function SBM_Bar:SetLocked(locked)
	self.locked = locked
end

function SBM_Bar:SetPosition(x,y)
	self.x = x
	self.y = y
	self.LongTimerFrame:SetPoint("TOPLEFT", UIParent, self.x, -self.y)
end

function SBM_Bar:SetBorderColor(color)
	self.LongTimerFrame:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
end

function SBM_Bar:IsLocked()
	return self.locked
end

function SBM_Bar:SetVisible(visible)
	if (visible == true) then
		self.LongTimerFrame:Show()
	end
	
	if (visible == false) then
		self.LongTimerFrame:Hide()
	end
end

function SBM_Bar:IsVisible()
	return visible
end
