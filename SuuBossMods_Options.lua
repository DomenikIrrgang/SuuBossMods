local test = "test"

local GUIMenuOptions = { 
	{
		type = "group",
		value = "Bars",
		name = "Bars",
		text = "Bars",
		childGroups = "select",
		icon = "Interface\\Icons\\INV_Drink_05",
		args = {
			intro = {
				order = 1,
				type = "description",
				name = "Here you can set up your bars",
			}
		}
	},
	{
		value = "B",
		text = "Bravo",
		children = {
			{ 
				value = "C", 
				text = "Charlie"
			},
			{
				value = "D",	
				text = "Delta",
				children = { 
					{ 
						value = "E",
						text = "Echo"
					} 
				}
			}
		}
	}
}
local GUIMenuSV = GUIMenuSV or {
	text = "LOL"
}  

local icon = LibStub("LibDBIcon-1.0")

local SuuBossModsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("SuuBossMods!", {
	type = "data source",
	text = "SuuBossMods!",
	icon = "Interface\\Icons\\monk_ability_cherrymanatea",
	OnTooltipShow = function(tooltip)
		tooltip:SetText("SuuBossMods")
		tooltip:AddLine("Opens Config Window.", 1, 1, 1)
		tooltip:Show()
	end,
	OnClick = SuuBossMods["MinimapClick"],
})



local OnInit = function()
	local OptionsTable = GetOptionsTable()
	
	for i, Plugin in ipairs(SuuBossMods:GetPlugins()) do
		if (Plugin["GetOptionsTable"] ~= nil and Plugin.name ~= nil) then
			OptionsTable["args"].plugins["args"][Plugin.name] = Plugin:GetOptionsTable()

		end
	end	
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SuuBossMods", OptionsTable)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SuuBossMods", "SuuBossMods")
	
end

function GetOptionsTable()
return {
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
						toggle = {
							order = 1,
							type = "execute",
							name = "Start Test Timers",
							desc = "Starts some test timers.",
							func = function() SuuBossMods:UnlockAnchor()
								SuuBossMods:StartTimer("TestBar1", 20, 1, {["Text"] = "TEST MESSAGE1", ["Duration"] = 3, ["Start"] = 5})
								SuuBossMods:StartTimer("TestBar2", 17, 1, {["Text"] = "TEST MESSAGE2", ["Duration"] = 4, ["Start"] = 5})
								SuuBossMods:StartTimer("TestBar3", 14, 1, {["Text"] = "TEST MESSAGE3", ["Duration"] = 4, ["Start"] = 5})
								SuuBossMods:StartTimer("TestBar4", 11, 1, {["Text"] = "TEST MESSAGE4", ["Duration"] = 2, ["Start"] = 5})
								SuuBossMods:StartTimer("TestBar5", 8, 1, {["Text"] = "TEST MESSAGE5", ["Duration"] = 5, ["Start"] = 5})
								SuuBossMods:StartTimer("TestBar6", 5, 1, {["Text"] = "TEST MESSAGE6", ["Duration"] = 5, ["Start"] = 5})
							end,
						},
						soonbarthreshold = {
							order = 2,
							name = "SoonBar Threshold",
							desc = "Sets when the bar switches the anchor.",
							type = "range",
							width = "full",
							get = function(info) return SuuBossMods.db.profile.soonbar.threshold end,
							set = function(info, value) SuuBossMods.db.profile.soonbar.threshold = value end,
							min = 2, max = 25, step=1,
						},
						update_interval = {
							order = 3,
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
end

SuuBossMods:AddInitCallback(OnInit)

function SuuBossMods:CreateOptionsWindow()
	SuuBossMods.GUI = AceGUI:Create("Frame")
	SuuBossMods.GUI:SetCallback("OnClose",function(widget)
		AceGUI:Release(widget)
		GUICreated = false
	end)
	SuuBossMods.GUI:SetTitle(SuuBossMods.Info.Name)
	SuuBossMods.GUI:SetStatusText("v" .. SuuBossMods.Info.Version)
	SuuBossMods.GUI:SetLayout("Flow")
	
	local btn = AceGUI:Create("Button")
	btn:SetWidth(170)
	btn:SetText("Button !")
	btn:SetCallback("OnClick", function() print("Click!") end)	
	SuuBossMods.GUI:AddChild(btn)
	
	local treewidget = AceGUI:Create("TreeGroup")
	treewidget:SetTree(GUIMenuOptions)
	treewidget:SetStatusTable(GUIMenuSV)
	treewidget:SetFullWidth(true)
	treewidget:SetFullHeight(true)
	treewidget:SetCallback("OnGroupSelected", function(_,_,value)
		if (value == "Bars") then
			print("juhu")
		end
	end)
	SuuBossMods.GUI:AddChild(treewidget)
	
	
	GUICreated = true
end

function SuuBossMods:MinimapClick(ClickType)
	SuuBossMods:ShowOptionsWindow()
end

function SuuBossMods:InitMinimapButton()
	icon:Register("SuuBossMods!", SuuBossModsLDB, self.db.profile.minimap)
end

function SuuBossMods:ChangeMinimapButtonVisibility()
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	if self.db.profile.minimap.hide then
		icon:Hide("SuuBossMods!")
	else
		icon:Show("SuuBossMods!")
	end
end

function SuuBossMods:ShowOptionsWindow()
	if (GUICreated) then
		SuuBossMods.GUI.Hide(SuuBossMods.GUI)
	else
		SuuBossMods:CreateOptionsWindow()
	end
end