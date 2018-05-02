SuuBossMods_Options = {}
SuuBossMods_Options.__index = SuuBossMods_Options

setmetatable(SuuBossMods_Options, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function SuuBossMods_Options.new()
    local self = setmetatable({}, SuuBossMods_Options)
    SuuBossMods.eventDispatcher:addEventListener(self)
    self.optionsTable = optionsTable
    return self
end

function SuuBossMods_Options:getEvents()
    return {
      "SUUBOSSMODS_INIT_AFTER"
    }
end

function SuuBossMods_Options:addPlugin(plugin)
    self.optionsTable["args"].plugins["args"][plugin:getName()] = plugin:getOptionsTable()
end

function SuuBossMods_Options:SUUBOSSMODS_INIT_AFTER()
    SuuBossMods.eventDispatcher:dispatchEvent("OPTIONS_TABLE_INIT")
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SuuBossMods", self.optionsTable)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SuuBossMods", "SuuBossMods")
end

local optionsTable = {
	type = "group",
	args = {
		bars = {
			name = "Bars",
			type = "group",
			order = 1,
			childGroups = "select",
			args = {
				intro = {
					order = 1,
					type = "description",
					name = "Change bar settings.",
				},
				toggle = {
					order = 2,
					type = "execute",
					name = "Toggle Anchors",
					desc = "Toggle all Bar Anchors",
					func = function() SuuBossMods:UnlockAnchor()
					SuuBossMods.db.profile.mainbar.anchorX = MainBarAnchor.x 
					SuuBossMods.db.profile.mainbar.anchorY = MainBarAnchor.y
					SuuBossMods.db.profile.soonbar.anchorX = SoonBarAnchor.x
					SuuBossMods.db.profile.soonbar.anchorY = SoonBarAnchor.y
					end,
				},
				general = {
					order = 3,
					type = "group",
					name = "General",
					args = {
						soonbarthreshold = {
							order = 1,
							name = "SoonBar Threshold",
							desc = "Sets when the bar switches the anchor.",
							type = "range",
							width = "full",
							get = function(info) return SuuBossMods.db.profile.soonbar.threshold end,
							set = function(info, value) SuuBossMods.db.profile.soonbar.threshold = value end,
							min = 2, max = 25, step=1,
						},
						update_interval = {
							order = 2,
							name = "BarUpdate Frequency",
							desc = "Sets the rate at which the timer get updated.",
							type = "range",
							width = "full",
							get = function(info)
								return SuuBossMods.db.profile.core.timer.update_interval end,
							set = function(info, value) SuuBossMods.db.profile.core.timer.update_interval = value end,
							min = 0.01, max = 1, step=0.01,
						},
					}	
				},
				main_bars = {
					order = 4,
					type = "group",
					name = "MainBars",
					args = {
						width = {
							order = 1,
							name = "Width",
							width = "full",
							desc = "Sets the bar width.",
							type = "range",
							get = function(info) return SuuBossMods.db.profile.mainbar.width end,
							set = function(info, value) SuuBossMods:SetMainBarWidth(value) end,
							min = 100, max = 500, step=5,
						},
						height = {
							order = 2,
							name = "Height",
							width = "full",
							desc = "Sets the bar height.",
							type = "range",
							get = function(info) return SuuBossMods.db.profile.mainbar.height end,
							set = function(info, value) SuuBossMods:SetMainBarHeight(value) end,
							min = 20, max = 100, step=2,
						},
						growth = {
							order = 3,
							name = "GrowthDirection",
							width = "full",
							desc = "Sets the bars grow direction.",
							type = "select",
							get = function(info) return SuuBossMods.db.profile.mainbar.growth_direction end,
							set = function(info, value)
								SuuBossMods.db.profile.mainbar.growth_direction = value
								for i=0, MainBarCount - 1 do
									SuuBossMods:AnchorBar(MainBars,i, MainBarAnchor, SuuBossMods.db.profile.mainbar.growth_direction)
								end
							end,
							values = {
								['UP'] = "UP",
								['DOWN'] = "DOWN",
							},
						},
						color = {
							order = 4,
							name = "Bar Color",
							desc = "Sets the bar color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.mainbar.color.r,
								SuuBossMods.db.profile.mainbar.color.g,
								SuuBossMods.db.profile.mainbar.color.b,
								SuuBossMods.db.profile.mainbar.color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.mainbar.color.r = r
								SuuBossMods.db.profile.mainbar.color.g = g
								SuuBossMods.db.profile.mainbar.color.b = b
								SuuBossMods.db.profile.mainbar.color.a = a
								SuuBossMods:SetMainBarColor(SuuBossMods.db.profile.mainbar.color)
							end,
						},
						backgroundcolor = {
							order = 4,
							name = "Background Color",
							desc = "Sets the background color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.mainbar.background_color.r,
								SuuBossMods.db.profile.mainbar.background_color.g,
								SuuBossMods.db.profile.mainbar.background_color.b,
								SuuBossMods.db.profile.mainbar.background_color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.mainbar.background_color.r = r
								SuuBossMods.db.profile.mainbar.background_color.g = g
								SuuBossMods.db.profile.mainbar.background_color.b = b
								SuuBossMods.db.profile.mainbar.background_color.a = a
								SuuBossMods:SetMainBarBackgroundColor(SuuBossMods.db.profile.mainbar.background_color)
							end,
						},
						bordercolor = {
							order = 5,
							name = "Border Color",
							desc = "Sets the border color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.mainbar.border_color.r,
								SuuBossMods.db.profile.mainbar.border_color.g,
								SuuBossMods.db.profile.mainbar.border_color.b,
								SuuBossMods.db.profile.mainbar.border_color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.mainbar.border_color.r = r
								SuuBossMods.db.profile.mainbar.border_color.g = g
								SuuBossMods.db.profile.mainbar.border_color.b = b
								SuuBossMods.db.profile.mainbar.border_color.a = a
								SuuBossMods:SetMainBarBorderColor(SuuBossMods.db.profile.mainbar.border_color)
							end,
						},
					}	
				},
				soon_bars = {
					order = 5,
					type = "group",
					name = "SoonBars",
					args = {
						width = {
							order = 1,
							name = "Width",
							width = "full",
							desc = "Sets the bar width.",
							type = "range",
							get = function(info) return SuuBossMods.db.profile.soonbar.width end,
							set = function(info, value) SuuBossMods:SetSoonBarWidth(value) end,
							min = 100, max = 500, step=5,
						},
						height = {
							order = 2,
							name = "Height",
							desc = "Sets the bar height.",
							width = "full",
							type = "range",
							get = function(info) return SuuBossMods.db.profile.soonbar.height end,
							set = function(info, value) SuuBossMods:SetSoonBarHeight(value) end,
							min = 20, max = 100, step=2,
						},
						growth = {
							order = 3,
							name = "GrowthDirection",
							desc = "Sets the bars grow direction.",
							type = "select",
							width = "full",
							get = function(info) return SuuBossMods.db.profile.soonbar.growth_direction end,
							set = function(info, value)
								SuuBossMods.db.profile.soonbar.growth_direction = value
								for i=0, SoonBarCount - 1 do
									SuuBossMods:AnchorBar(SoonBars,i, SoonBarAnchor, SuuBossMods.db.profile.soonbar.growth_direction)
								end
							end,
							values = {
								['UP'] = "UP",
								['DOWN'] = "DOWN",
							},
						},
						color = {
							order = 4,
							name = "Bar Color",
							desc = "Sets the bar color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.soonbar.color.r,
								SuuBossMods.db.profile.soonbar.color.g,
								SuuBossMods.db.profile.soonbar.color.b,
								SuuBossMods.db.profile.soonbar.color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.soonbar.color.r = r
								SuuBossMods.db.profile.soonbar.color.g = g
								SuuBossMods.db.profile.soonbar.color.b = b
								SuuBossMods.db.profile.soonbar.color.a = a
								SuuBossMods:SetSoonBarColor(SuuBossMods.db.profile.soonbar.color)
							end,
						},
						backgroundcolor = {
							order = 4,
							name = "Background Color",
							desc = "Sets the background color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.soonbar.background_color.r,
								SuuBossMods.db.profile.soonbar.background_color.g,
								SuuBossMods.db.profile.soonbar.background_color.b,
								SuuBossMods.db.profile.soonbar.background_color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.soonbar.background_color.r = r
								SuuBossMods.db.profile.soonbar.background_color.g = g
								SuuBossMods.db.profile.soonbar.background_color.b = b
								SuuBossMods.db.profile.soonbar.background_color.a = a
								SuuBossMods:SetSoonBarBackgroundColor(SuuBossMods.db.profile.soonbar.background_color)
							end,
						},
						bordercolor = {
							order = 5,
							name = "Border Color",
							desc = "Sets the border color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.soonbar.border_color.r,
								SuuBossMods.db.profile.soonbar.border_color.g,
								SuuBossMods.db.profile.soonbar.border_color.b,
								SuuBossMods.db.profile.soonbar.border_color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.soonbar.border_color.r = r
								SuuBossMods.db.profile.soonbar.border_color.g = g
								SuuBossMods.db.profile.soonbar.border_color.b = b
								SuuBossMods.db.profile.soonbar.border_color.a = a
								SuuBossMods:SetSoonBarBorderColor(SuuBossMods.db.profile.soonbar.border_color)
							end,
						},
					}
				}
			}
		},
		MessageDisplay = {
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
					func = function() SuuBossMods:UnlockMessageAnchor()
					SuuBossMods.db.profile.timermessagedisplay.anchorX = TimerMessageDisplay.x 
					SuuBossMods.db.profile.timermessagedisplay.anchorY = TimerMessageDisplay.y
					end,
				},
				general = {
					order = 3,
					type = "group",
					name = "General",
					args = {
						update_interval = {
							order = 1,
							name = "Message Update Frequency",
							desc = "Sets the rate at which the messages get updated.",
							type = "range",
							width = "full",
							get = function(info)
								return SuuBossMods.db.profile.core.message.update_interval end,
							set = function(info, value) SuuBossMods.db.profile.core.message.update_interval = value end,
							min = 0.01, max = 1, step=0.01,
						},
						size = {
							order = 2,
							name = "Font Size",
							desc = "Sets the font size of the display.",
							type = "range",
							width = "full",
							get = function(info) return SuuBossMods.db.profile.timermessagedisplay.size end,
							set = function(info, value) 
								SuuBossMods.db.profile.timermessagedisplay.size = value
								TimerMessageDisplay:SetFontSize(SuuBossMods.db.profile.timermessagedisplay.size)
							end,
							min = 15, max = 32, step=1,
						},
						color = {
							order = 4,
							name = "Font Color",
							desc = "Sets the font color.",
							type = "color",
							hasAlpha = true,
							get = function(info) return SuuBossMods.db.profile.timermessagedisplay.color.r,
								SuuBossMods.db.profile.timermessagedisplay.color.g,
								SuuBossMods.db.profile.timermessagedisplay.color.b,
								SuuBossMods.db.profile.timermessagedisplay.color.a
							end,
							set = function(info, r, g, b, a) 
								SuuBossMods.db.profile.timermessagedisplay.color.r = r
								SuuBossMods.db.profile.timermessagedisplay.color.g = g
								SuuBossMods.db.profile.timermessagedisplay.color.b = b
								SuuBossMods.db.profile.timermessagedisplay.color.a = a
								TimerMessageDisplay:SetTextColor(SuuBossMods.db.profile.timermessagedisplay.color)
							end,
						},
					}	
				},
			}
		},
		plugins = {
			name = "Plugins",
			type = "group",
			order = 1,
			childGroups = "select",
			args = {
				intro = {
					order = 1,
					type = "description",
					name = "Change settings of a plugin.",
				},
			},
		},
		profile = {
			name = "Profile",
			type = "group",
			order = 2,
			childGroups = "select",
			args = {
				intro = {
					order = 1,
					type = "description",
					name = "Change your profile settings.",
				},
				currentprofile = {
							order = 2,
							name = "Current Profile",
							width = "full",
							desc = "Sets the current profile.",
							type = "select",
							get = function(info) 
								for k,v in pairs(SuuBossMods.db:GetProfiles()) do
									if (v == SuuBossMods.db:GetCurrentProfile()) then
										return k
									end
								end
							end,
							set = function(info, value)
								SuuBossMods.db:SetProfile(SuuBossMods.db:GetProfiles()[value])
							end,
							values = SuuBossMods.db:GetProfiles(),
				},
				copyprofile = {
							order = 3,
							name = "Copy from other Profile",
							width = "full",
							desc = "Copies settings from another profile and overides the current ones.",
							type = "select",
							get = function(info) 
								return "Profiles"
							end,
							set = function(info, value)
								SuuBossMods.db:CopyProfile(SuuBossMods.db:GetProfiles()[value], true)
							end,
							values = SuuBossMods.db:GetProfiles(),
				}
			}
		},
	}
}