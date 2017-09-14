local plugin = SuuBossMods:NewPlugin("RangeCheck")

function plugin:OnInit()
	self.width = 200
	self.height = 200
	self.x = SuuBossMods.db.profile.plugins[self.name].anchorX
	self.y = SuuBossMods.db.profile.plugins[self.name].anchorY
	self.range = 40
	self.max_count = 0
	self.mode = "SINGLE"
	self.scale = SuuBossMods.db.profile.plugins[self.name].scale
	self.zoom = 55 / self.range
	self.locked = SuuBossMods.db.profile.plugins[self.name].locked
	self.Background = CreateFrame("Frame", "BACKGROUND", UIParent)
	self.Background:SetSize((self.width + 3) * self.scale, (self.height + 6) * self.scale)
	self.Background:SetPoint("TOPLEFT", UIParent, self.x, -self.y)

	self.Background:SetBackdrop({
		bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3, },
	})
	
	self:SetBackgroundColor(SuuBossMods.db.profile.plugins[self.name].background_color)
	self:SetBorderColor(SuuBossMods.db.profile.plugins[self.name].border_color)
	
	self.Player = self.Background:CreateTexture(nil, "BACKGROUND", nil, 4)
	self.Player:SetTexture("Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura118")
	self.Player:SetPoint("CENTER", self.Background, "CENTER", 0, 0)
	self.Player:SetWidth(20 * self.scale)
    self.Player:SetHeight(20 * self.scale)
	self.Player:SetVertexColor(1,0,0,0.5)
	self.RangeCheck = LibStub("LibRangeCheck-2.0")
	
    self.RangeIndicator = self.Background:CreateTexture(nil, "BACKGROUND", nil, 2)
    self.RangeIndicator:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_White")
    self.RangeIndicator:SetVertexColor(0,1,0,0.5)
	self.RangeIndicator:SetWidth(self.range * 2 * self.zoom * self.scale)
	self.RangeIndicator:SetHeight(self.range * 2 * self.zoom * self.scale)
	self.RangeIndicator:SetPoint("CENTER", self.Background, "CENTER", 0, 0)
	
	self.Titel = self.Background:CreateFontString(nil, "OVERLAY")
	self.Titel:SetPoint("CENTER", self.Background, "CENTER", 0, 113 * self.scale)
	self.Titel:SetFont("Fonts\\FRIZQT__.TTF", 16 * self.scale, "OUTLINE")
	self.Titel:SetJustifyH("CENTER")
	self.Titel:SetShadowOffset(1, -1)
	self.Titel:SetTextColor(1, 1, 1)
	self.Titel:SetText("Range: " .. self.range)
    	
	self.Raid = {}
	for i=1,20 do
        self.Raid[i] = self.Background:CreateTexture(nil, "BACKGROUND", nil, 3)
        self.Raid[i]:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_Smooth_Border")
        self.Raid[i]:SetWidth(15 * self.scale)
        self.Raid[i]:SetHeight(15 * self.scale)
		self.Raid[i]:SetPoint("CENTER", self.Background, "CENTER", 0, 0)
        self.Raid[i]:Hide()
    end
	

	
	self.Background:SetScript("OnMouseDown", function()
		if (self.locked ~= true) then
			self.Background:SetMovable(true)
			self.Background:StartMoving(self.Background)
		end
	end)

	self.Background:SetScript("OnMouseUp", function()
		self.Background:StopMovingOrSizing()
		self.Background:SetMovable(false)
		self.x = self.Background:GetLeft()
		self.y = (GetScreenHeight() -self.Background:GetTop())
		SuuBossMods.db.profile.plugins[self.name].anchorX = self.x 
		SuuBossMods.db.profile.plugins[self.name].anchorY = self.y 
	end)
	
	self.Background:EnableMouse(false)
	
	local PlayerInRange = false
	local LastCheck = 0
	self.Background:SetScript("OnUpdate", function(_, renderTime)
		local px, py = UnitPosition("player")
		PlayerInRange = false
		LastCheck = LastCheck + renderTime
		if (LastCheck >= SuuBossMods.db.profile.plugins[self.name].update_interval) then
			local PlayersInRange = 0
			for j = 1,20 do
				if (UnitExists("raid".. j) and not UnitIsDead("raid"..j) and UnitName("raid"..j) ~= UnitName("player")) then
            
					local ax, ay = UnitPosition("raid"..j)
					local da = ((px-ax)^2+(py-ay)^2)^(1/2)
					if (da <  92 / self.zoom)  then
						local radian = math.atan2((py - ay), (px - ax)) - GetPlayerFacing()
						local ox = da * self.zoom * self.scale * math.cos(radian)  
						local oy = da * self.zoom * self.scale * math.sin(radian)  
						local colors = RAID_CLASS_COLORS[select(2, UnitClass("raid"..j))]
	
						self.Raid[j]:SetPoint("CENTER", self.Background, "CENTER", oy, -ox)
						self.Raid[j]:SetVertexColor(colors.r, colors.g, colors.b, 1)
						self.Raid[j]:Show()
					
					else
						self.Raid[j]:Hide()
					end
				
					if (da < self.range) then
						PlayersInRange = PlayersInRange + 1
						PlayerInRange = true
					end
				end
			end
			if (self.mode == "SINGLE") then
				if (PlayersInRange > self.max_count) then
					self.RangeIndicator:SetVertexColor(1,0,0.5)
				else
					self.RangeIndicator:SetVertexColor(0,1,0.5)
				end
			else
				if (self.mode == "MULTI") then
					if (PlayersInRange < self.max_count) then
						self.RangeIndicator:SetVertexColor(1,0,0.5)
					else
						self.RangeIndicator:SetVertexColor(0,1,0.5)
					end
				end
			end
			LastCheck = 0
		end
	end)
	self:Hide()
end

function SuuBossMods:ShowRange(range)
	plugin.SetRange(plugin, range)
	plugin.Show(plugin)
end

function SuuBossMods:HideRange()
	plugin.Hide(plugin)
end

function plugin:SetRange(range)
	self.range = range
	self.zoom = 55 / self.range 
	self.RangeIndicator:SetWidth(self.range * 2 * self.scale * self.zoom)
	self.RangeIndicator:SetHeight(self.range * 2 * self.scale * self.zoom)
	self.Titel:SetText("Range: " .. self.range)
end

function plugin:Show()
	self.Background:Show()
end

function plugin:SlashInput(input)
	if (string.match(input, "range")) then
		local inputValues = {}
		i = 1
		for word in input:gmatch("%w+") do table.insert(inputValues, word) end
		local range
		
		if (inputValues[2] == "hide") then
			self:Hide()
		else	
			if inputValues[2] == nil then 
				range = 8
			else
				range = tonumber(inputValues[2])
			end
		
			if (tonumber(range) ~= nil and tonumber(range) >= 2) then
				SuuBossMods:ShowRange(range)
			end	
		end
	end
end

function plugin:GetOptionsTable()
 return {
					order = 3,
					type = "group",
					name = self.name,
					args = {
						locked = {
							order = 1,
							name = "Lock",
							desc = "Locks the radar.",
							type = "toggle",
							get = function(info)
								return SuuBossMods.db.profile.plugins[self.name].locked end,
							set = function(info, value) SuuBossMods.db.profile.plugins[self.name].locked = value 
									self.locked = value
							end,

						},
						update_interval = {
							order = 2,
							name = "Radar Update Frequency",
							desc = "Sets the rate at which the radar get updated.",
							type = "range",
							width = "full",
							get = function(info)
								return SuuBossMods.db.profile.plugins[self.name].update_interval end,
							set = function(info, value) SuuBossMods.db.profile.plugins[self.name].update_interval = value end,
							min = 0.01, max = 1, step=0.01,
						},
						size = {
							order = 3,
							name = "Scale",
							desc = "Sets the scale of the radar.",
							type = "range",
							width = "full",
							get = function(info) return SuuBossMods.db.profile.plugins[self.name].scale end,
							set = function(info, value) 
								SuuBossMods.db.profile.plugins[self.name].scale = value
								self:SetScale(value)
							end,
							min = 0.2, max = 2, step=0.025,
						},
						background_color = {
							order = 4,
							name = "Background Color",
							desc = "Sets the background color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.plugins[self.name].background_color.r,
								SuuBossMods.db.profile.plugins[self.name].background_color.g,
								SuuBossMods.db.profile.plugins[self.name].background_color.b,
								SuuBossMods.db.profile.plugins[self.name].background_color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.plugins[self.name].background_color.r = r
								SuuBossMods.db.profile.plugins[self.name].background_color.g = g
								SuuBossMods.db.profile.plugins[self.name].background_color.b = b
								SuuBossMods.db.profile.plugins[self.name].background_color.a = a
								self:SetBackgroundColor(SuuBossMods.db.profile.plugins[self.name].background_color)
							end,
						},
						border_color = {
							order = 4,
							name = "Border Color",
							desc = "Sets the border color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.plugins[self.name].border_color.r,
								SuuBossMods.db.profile.plugins[self.name].border_color.g,
								SuuBossMods.db.profile.plugins[self.name].border_color.b,
								SuuBossMods.db.profile.plugins[self.name].border_color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.plugins[self.name].border_color.r = r
								SuuBossMods.db.profile.plugins[self.name].border_color.g = g
								SuuBossMods.db.profile.plugins[self.name].border_color.b = b
								SuuBossMods.db.profile.plugins[self.name].border_color.a = a
								self:SetBorderColor(SuuBossMods.db.profile.plugins[self.name].border_color)
							end,
						},
					}	
				}
end

function plugin:SetBackgroundColor(color)
	self.Background:SetBackdropColor(color.r, color.g, color.b, color.a)
end

function plugin:SetBorderColor(color)
	self.Background:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
end

function plugin:SetScale(scale)
	self.scale = scale
	self.Background:SetSize((self.width + 3) * self.scale, (self.height + 6) * self.scale)
	self.Player:SetWidth(20 * self.scale)
    self.Player:SetHeight(20 * self.scale)
	self.RangeIndicator:SetWidth(self.range * 2 * self.zoom * self.scale)
	self.RangeIndicator:SetHeight(self.range * 2 * self.zoom * self.scale)
	self.Titel:SetPoint("CENTER", self.Background, "CENTER", 0, 113 * self.scale)
	self.Titel:SetFont("Fonts\\FRIZQT__.TTF", 16 * self.scale, "OUTLINE")
	for i=1,20 do
        self.Raid[i]:SetWidth(15 * self.scale)
        self.Raid[i]:SetHeight(15 * self.scale)
    end
end

function plugin:GetDefaults()
	return {
		scale = 1,
		locked = false,
		update_interval = 0.05,
		background_color = {["r"] = 10/255, ["g"] = 10/255, ["b"] = 10/255, ["a"] = 0.5},
		border_color = {["r"] = 0, ["g"] = 0, ["b"] = 0, ["a"] = 1},
		anchorX = 1000,
		anchorY = 500,
	}
end
function plugin:Hide()
	self.Background:Hide()
end

function plugin:COMBAT_LOG_EVENT_UNFILTERED(...)

end

