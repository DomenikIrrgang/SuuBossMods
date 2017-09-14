local plugin = SuuBossMods:NewPlugin("Radar")

function plugin:OnInit()
	self.width = 200
	self.height = 200
	self.x = SuuBossMods.db.profile.plugins[self.name].anchorX
	self.y = SuuBossMods.db.profile.plugins[self.name].anchorY
	self.range = 40
	self.max_count = 0
	self.search = nil
	self.rangeTextures = {}
	self.scale = SuuBossMods.db.profile.plugins[self.name].scale
	self.zoom = 40 / self.range
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
	
	for i=1, 30 do
		self.rangeTextures[i] = self.Background:CreateTexture(nil, "BACKGROUND", nil, 2)
		self.rangeTextures[i]:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_White")
		self.rangeTextures[i]:SetVertexColor(0,1,0,0.5)
		self.rangeTextures[i]:SetWidth(self.range * 2 * self.zoom * self.scale)
		self.rangeTextures[i]:SetHeight(self.range * 2 * self.zoom * self.scale)
	end
	
	self.playerTexture = self.Background:CreateTexture(nil, "BACKGROUND", nil, 2)
	self.playerTexture:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_White")
	self.playerTexture:SetVertexColor(0,1,0,0.5)
	self.playerTexture:SetWidth(self.range * 2 * self.zoom * self.scale)
	self.playerTexture:SetHeight(self.range * 2 * self.zoom * self.scale)
	self.playerTexture:SetPoint("CENTER", self.Background, "CENTER", 0, 0)
	
	self.Player = self.Background:CreateTexture(nil, "BACKGROUND", nil, 4)
	self.Player:SetTexture("Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura118")
	self.Player:SetPoint("CENTER", self.Background, "CENTER", 0, 0)
	self.Player:SetWidth(20 * self.scale)
    self.Player:SetHeight(20 * self.scale)
	self.Player:SetVertexColor(1,0,0,0.5)
	self.RangeCheck = LibStub("LibRangeCheck-2.0")
	
	--[[
    self.RangeIndicator = self.Background:CreateTexture(nil, "BACKGROUND", nil, 2)
    self.RangeIndicator:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_White")
    self.RangeIndicator:SetVertexColor(0,1,0,0.5)
	self.RangeIndicator:SetWidth(self.range * 2 * self.zoom * self.scale)
	self.RangeIndicator:SetHeight(self.range * 2 * self.zoom * self.scale)
	self.RangeIndicator:SetPoint("CENTER", self.Background, "CENTER", 0, 0)
	--]]
	
	self.Titel = self.Background:CreateFontString(nil, "OVERLAY")
	self.Titel:SetPoint("CENTER", self.Background, "CENTER", 0, 113 * self.scale)
	self.Titel:SetFont("Fonts\\FRIZQT__.TTF", 16 * self.scale, "OUTLINE")
	self.Titel:SetJustifyH("CENTER")
	self.Titel:SetShadowOffset(1, -1)
	self.Titel:SetTextColor(1, 1, 1)
	self.Titel:SetText("Range: " .. self.range)
    	
	self.Raid = {}
	for i=1,30 do
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
	
	local LastCheck = 0
	self.Background:SetScript("OnUpdate", function(_, renderTime)
		local px, py = UnitPosition("player")
		PlayerInRange = false
		LastCheck = LastCheck + renderTime
		if (LastCheck >= SuuBossMods.db.profile.plugins[self.name].update_interval) then
			local PlayersInRange = 0
			for j = 1,30 do
				if (UnitExists("raid".. j) and not UnitIsDead("raid"..j) and UnitName("player") ~= UnitName("raid" .. j)) then
            
					local ax, ay = UnitPosition("raid"..j)
					local da = ((px-ax)^2+(py-ay)^2)^(1/2)
					if (da <  92 / self.zoom)  then
						local radian = math.atan2((py - ay), (px - ax)) - GetPlayerFacing()
						local ox = da * self.zoom * self.scale * math.cos(radian)  
						local oy = da * self.zoom * self.scale * math.sin(radian)  
						local colors = RAID_CLASS_COLORS[select(2, UnitClass("raid"..j))]
	
						if (UnitName("raid"..j) ~= UnitName("player")) then
							self.Raid[j]:SetPoint("CENTER", self.Background, "CENTER", oy, -ox)
							self.Raid[j]:SetVertexColor(colors.r, colors.g, colors.b, 1)
							self.Raid[j]:Show()
						else
							self.Raid[j]:Hide()
						end
						
						if (self.search ~= nil and UnitName("raid" .. j) ~= UnitName("player")) then
							if (self.search.type == "BUFF") then
								local found, remainingTime = self:HasBuff("raid" .. j, self.search.spellID)
								if (found) then
									self.rangeTextures[j]:SetPoint("CENTER", self.Background, "CENTER", oy, -ox)
									self.rangeTextures[j]:Show()
									if (da < self.range) then
										self.rangeTextures[j]:SetVertexColor(1,0,0.5)
									else
										self.rangeTextures[j]:SetVertexColor(0,1,0.5)
									end
								else
									self.rangeTextures[j]:Hide()
								end
							else
								local found, remainingTime = self:HasDebuff("raid" .. j, self.search.spellID)
								if (found) then
									self.rangeTextures[j]:SetPoint("CENTER", self.Background, "CENTER", oy, -ox)
									self.rangeTextures[j]:Show()
									if (da < self.range) then
										self.rangeTextures[j]:SetVertexColor(1,0,0.5)
									else
										self.rangeTextures[j]:SetVertexColor(0,1,0.5)
									end
								else
									self.rangeTextures[j]:Hide()
								end
							end
						end					
					else
						self.Raid[j]:Hide()
						self.rangeTextures[j]:Hide()
					end
					
					if (da < self.search.range) then
						PlayerInRange = true
					end
				end
				
				if (self.search ~= nil and self:HasBuff("player", self.search.spellID) == true) then
					self.playerTexture:Show()
					if (PlayerInRange == true) then
						self.playerTexture:SetVertexColor(1,0,0.5)
					else
						self.playerTexture:SetVertexColor(0,1,0.5)
					end
				else
					self.playerTexture:Hide()
				end 
			end
			LastCheck = 0
			PlayerInRange = false
		end
	end)
	self:Hide()
end

function SuuBossMods:ShowRadar(search)
	plugin:SetSearch(search)
	plugin.Show(plugin)
end

function SuuBossMods:HideRadar()
	plugin.Hide(plugin)
end

function plugin:SetPlayerRange(index, range)
	if (range == 0 or range == nil) then
		self.playerRange[index] = nil
	else 
		self.playerRange[index] = range
	end
end

function plugin:SetRange(range)
	self.range = range
	self.zoom = 40 / self.range 
	for i=1, 30 do
		self.rangeTextures[i]:SetWidth(self.range * 2 * self.zoom * self.scale)
		self.rangeTextures[i]:SetHeight(self.range * 2 * self.zoom * self.scale)
	end
	self.playerTexture:SetWidth(self.range * 2 * self.zoom * self.scale)
	self.playerTexture:SetHeight(self.range * 2 * self.zoom * self.scale)
	self.Titel:SetText("Range: " .. self.range)
end

function plugin:Show()
	self.Background:Show()
end

function plugin:SlashInput(input)
	if (string.match(input, "radar")) then
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
				SuuBossMods:ShowRadar({["type"] = "BUFF", ["spellID"] = 115921, ["range"] = 10})
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

function plugin:SetSearch(search) 
	if (search["type"] ~= nil and search["spellID"] ~= nil and search["range"] ~= nil) then
		self.search = search
		self:SetRange(self.search.range)
	end
end

function plugin:HasDebuff(unit, spellID)
	for i = 1, 40 do
		local _, _, _, _, _, duration, expires, _, _, _, spellId = UnitDebuff(unit, i)
		if (spellID == spellId) then
			return true, expires - GetTime()
		end
	end
	return false
end

function plugin:HasBuff(unit, spellID)
	for i = 1, 40 do
		local _, _, _, _, _, duration, expires, _, _, _, spellId = UnitBuff(unit, i)
		if (spellID == spellId) then
			return true, expires - GetTime()
		end
	end
	return false
end

function plugin:SetScale(scale)
	self.scale = scale
	self.Background:SetSize((self.width + 3) * self.scale, (self.height + 6) * self.scale)
	self.Player:SetWidth(20 * self.scale)
    self.Player:SetHeight(20 * self.scale)
	self.Titel:SetPoint("CENTER", self.Background, "CENTER", 0, 113 * self.scale)
	self.Titel:SetFont("Fonts\\FRIZQT__.TTF", 16 * self.scale, "OUTLINE")
	for i=1,30 do
        self.Raid[i]:SetWidth(15 * self.scale)
        self.Raid[i]:SetHeight(15 * self.scale)
    end
	
	for i=1, 30 do
		self.rangeTextures[i]:SetWidth(self.range * 2 * self.zoom * self.scale)
		self.rangeTextures[i]:SetHeight(self.range * 2 * self.zoom * self.scale)
	end
	
	self.playerTexture:SetWidth(self.range * 2 * self.zoom * self.scale)
	self.playerTexture:SetHeight(self.range * 2 * self.zoom * self.scale)
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

