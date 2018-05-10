SuuBossMods_Options = {}
SuuBossMods_Options.__index = SuuBossMods_Options

setmetatable(SuuBossMods_Options, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

--[[
	Creates new options.
--]]
function SuuBossMods_Options.new()
	local self = setmetatable({}, SuuBossMods_Options)
	self.name = "options"
    SuuBossMods.eventDispatcher:addEventListener(self)
    return self
end

--[[
  Returns the customevents that need to be handled by options.

  @return Customevents option needs to handle.
--]]
function SuuBossMods_Options:getCustomEvents()
    return {
      "SUUBOSSMODS_INIT_AFTER"
    }
end

--[[
	Registers OptionsTables and invokes the OPTIONS_TABLE_INIT event
--]]
function SuuBossMods_Options:SUUBOSSMODS_INIT_AFTER()
	SuuBossMods.eventDispatcher:dispatchEvent("OPTIONS_TABLE_INIT")
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SuuBossMods", self.getOptionsTable)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SuuBossMods", "SuuBossMods")
end

--[[
	Dynamically builds the optionstable to be displayed in the GUI.

  @return The optionstable.
--]]
function SuuBossMods_Options:getOptionsTable()
	local optionsTable = {
		type = "group",
		args = {},
    }
    optionsTable.args["messagedisplay"] = SuuBossMods.messageDisplay:getOptionsTable()
	optionsTable.args["modules"] = SuuBossMods_Options.getModulesTable()
	optionsTable.args["plugins"] = SuuBossMods_Options.getPluginsTable()
	optionsTable.args["profile"] = SuuBossMods_Options.getProfileTable()
	return optionsTable
end

function SuuBossMods_Options:getModulesTable()
	local modules = {
		name = "Modules",
		type = "group",
		order = 1,
		childGroups = "select",
		args = {
			intro = {
				order = 1,
				type = "description",
				name = "Change settings of a module.",
			},
		},
	}
	for key, module in pairs(SuuBossMods.dungeonModuleLoader:getModules()) do
		modules.args[module:getName()] = module:getOptionsTable()
	end
	return modules
end

--[[
	Dynamically creates the table for plugin options based on the plugins that are currently
	loaded.

	@return Plugin optionstable.
--]]
function SuuBossMods_Options:getPluginsTable()
	local plugins = {
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
	}
	for key, plugin in pairs(SuuBossMods.pluginHandler:getPlugins()) do
		plugins.args[plugin:getName()] = plugin:getOptionsTable()
	end
	return plugins
end

--[[
	Dynamically creates the table for profile options.

	@return Profile options.
--]]
function SuuBossMods_Options:getProfileTable()
	return {
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
							for k,v in pairs(SuuBossMods.profileHandler.db:GetProfiles()) do
								if (v == SuuBossMods.profileHandler.db:GetCurrentProfile()) then
									return k
								end
							end
						end,
						set = function(info, value)
							SuuBossMods.profileHandler.db:SetProfile(SuuBossMods.profileHandler.db:GetProfiles()[value])
						end,
						values = SuuBossMods.profileHandler.db:GetProfiles(),
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
							SuuBossMods.profileHandler.db:CopyProfile(SuuBossMods.profileHandler.db:GetProfiles()[value], true)
						end,
						values = SuuBossMods.profileHandler.db:GetProfiles(),
			}
		}
	}
end