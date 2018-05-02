local plugin = SuuBossMods:NewPlugin("EncounterTimer")

function plugin:OnInit()
	self.display = SBM_Text("TEST MESSAGE",
		SuuBossMods.db.profile.plugins[self.name].anchorX,
		SuuBossMods.db.profile.plugins[self.name].anchorY,
		SuuBossMods.db.profile.plugins[self.name].font_size
	)
	self.display:SetTextColor(SuuBossMods.db.profile.plugins[self.name].font_color)
	self.display:Hide()
	self.enabled = SuuBossMods.db.profile.plugins[self.name].enabled
	self.startTime = GetTime()
end

function plugin:SlashInput(input)
	if (string.match(input, "encountertimer")) then
		print(input)
	end
end

function plugin:ToggleAnchor()
	self.display:SetVisible(not self.display:IsVisible())
	self.display:SetLocked(not self.display:IsLocked())
	self.display:SetText("MOVE ME")
end

function plugin:GetDefaults()
	return {
		locked = true,
		font_color = {["r"] = 10/255, ["g"] = 10/255, ["b"] = 10/255, ["a"] = 0.5},
		font_size = 24,
		anchorX = GetScreenWidth() / 2,
		anchorY = GetScreenHeight() / 4,
		enabled = false,
	}
end

function plugin:ENCOUNTER_START(...)
	if (self.enabled) then
		self.startTime = GetTime()
		self.display:SetVisible(true)
	end
end

function plugin:ENCOUNTER_END(...)
	if (self.enabled) then
		self.display:SetVisible(false)
	end
end

function plugin:Update(renderTime)
	if (self.enabled and self.display:IsVisible()) then
		self.display:SetText(string.format("%.2f", tostring(GetTime() - self.startTime)))
	end
end

function plugin:GetOptionsTable()
 return {
			order = 3,
			type = "group",
			name = self.name,
			args = {
				enabled = {
					order = 2,
					name = "Enabled",
					desc = "Enabled Plugin.",
					type = "toggle",
					get = function(info)
						return SuuBossMods.db.profile.plugins[self.name].enabled end,
					set = function(info, value)
						SuuBossMods.db.profile.plugins[self.name].enabled = value 
						self.enabled = value
					end,
				},
				locked = {
					order = 2,
					type = "execute",
					name = "Toggle Anchor",
					desc = "Toggle MessageDisplay Anchor",
					func = function()
						self:ToggleAnchor()
						SuuBossMods.db.profile.plugins[self.name].anchorX = self.display.x 
						SuuBossMods.db.profile.plugins[self.name].anchorY = self.display.y
					end,
				},
				size = {
					order = 3,
					name = "Font Size",
					desc = "Sets the font size of the display.",
					type = "range",
					width = "full",
					get = function(info) return SuuBossMods.db.profile.plugins[self.name].font_size end,
					set = function(info, value) 
						SuuBossMods.db.profile.plugins[self.name].font_size = value
						self.display:SetFontSize(value)
					end,
					min = 10, max = 64, step=1,
				},
				font_color = {
					order = 4,
					name = "Font Color",
					desc = "Sets the font color of the display.",
					type = "color",
					hasAlpha = true,
					get = function(info)
						return SuuBossMods.db.profile.plugins[self.name].font_color.r,
						SuuBossMods.db.profile.plugins[self.name].font_color.g,
						SuuBossMods.db.profile.plugins[self.name].font_color.b,
						SuuBossMods.db.profile.plugins[self.name].font_color.a
					end,
					set = function(info, r, g, b, a) 
						SuuBossMods.db.profile.plugins[self.name].font_color.r = r
						SuuBossMods.db.profile.plugins[self.name].font_color.g = g
						SuuBossMods.db.profile.plugins[self.name].font_color.b = b
						SuuBossMods.db.profile.plugins[self.name].font_color.a = a
						self.display:SetTextColor(SuuBossMods.db.profile.plugins[self.name].font_color)
					end,
				},
			}	
		}
end
