local plugin = SuuBossMods:NewPlugin("Reminder")

function plugin:OnInit()
	self.display = SBM_Text("TEST MESSAGE",
		SuuBossMods.db.profile.plugins[self.name].anchorX,
		SuuBossMods.db.profile.plugins[self.name].anchorY,
		SuuBossMods.db.profile.plugins[self.name].font_size
	)
	self.display:SetTextColor(SuuBossMods.db.profile.plugins[self.name].font_color)
	self.display:Hide()
end

function plugin:SlashInput(input)
	if (string.match(input, "reminder")) then
		print(input)
	end
end

function plugin:ToggleAnchor()
	self.display:SetVisible(not self.display:IsVisible())
	self.display:SetLocked(not self.display:IsLocked())
	self.display:SetText("MOVE ME")
end

function plugin:GetOptionsTable()
 return {
			order = 3,
			type = "group",
			name = self.name,
			args = {
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
					min = 10, max = 42, step=1,
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

function plugin:SetScale(scale)

end

function plugin:GetDefaults()
	return {
		locked = true,
		font_color = {["r"] = 10/255, ["g"] = 10/255, ["b"] = 10/255, ["a"] = 0.5},
		font_size = 16,
		anchorX = 1000,
		anchorY = 500,
	}
end
function plugin:Hide()

end

function plugin:COMBAT_LOG_EVENT_UNFILTERED(...)

end