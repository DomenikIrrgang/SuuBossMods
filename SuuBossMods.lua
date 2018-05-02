---------------------------------------------------------------------------------------------------
-- SuuBossMods_Core
---------------------------------------------------------------------------------------------------


SuuBossMods = LibStub("AceAddon-3.0"):NewAddon("SuuBossMods", "AceConsole-3.0")

local OnInitCallbacks = {}

local Plugins = {}
local Modules = {}
local ActiveModule

local defaults = {
	profile = {
		mainbar = {
			height = 35,
			width = 400,
			anchorX = 1500,
			anchorY = 250,
			color = {['r'] = 0, ['g'] = 59/255, ['b'] = 207/255, ['a'] = 0.7},
			background_color = {['r'] = 112/255, ['g'] = 154/255, ['b'] = 1, ['a'] = 0.5},
			border_color = {['r'] = 0, ['g'] = 0, ['b'] = 0, ['a'] = 1},
			growth_direction = "DOWN",
		},
		soonbar = {
			height = 35,
			width = 400,
			anchorX = 700,
			anchorY = 700,
			color = {['r'] = 1, ['g'] = 0/255, ['b'] = 0/255, ['a'] = 0.7},
			background_color = {['r'] = 0.3, ['g'] = 0, ['b'] = 0, ['a'] = 0.5},
			border_color = {['r'] = 0, ['g'] = 0, ['b'] = 0, ['a'] = 1},
			growth_direction = "DOWN",
			threshold = 10,
		},
		timermessagedisplay = {
			anchorX = 811,
			anchorY = 307,
			color = {['r'] = 1, ['g'] = 0.2, ['b'] = 0.2, ['a'] = 1},
			size = 26,
		},
		core = {
			timer = {
				update_interval = 0.05
			},
			message = {
				update_interval = 0.05
			},
		},
		modules = {
			['*'] = {
				enabled = true,
				locked = true,
				visible = true,
			},
		},
		plugins = {},
	},
}

MainBarAnchor = {}
SoonBarAnchor = {}
MainBars = {}
MainBarCount = 20
SoonBars = {}
SoonBarCount = 20
TimerMessageDisplay = {}

SuuBossMods.Core = {
	EncounterRunning = true,
	EncounterPulled = GetTime(),
	EncounterEnded = nil,
	EncounterDuration = 0,
	EncounterID = 0,
	EncounterDifficulty = nil,
	EncounterName = "",
	RaidSize = 0,
	EncounterResult = "No_Encounter_Pulled",
	SendTimerPrefix = "SBM_Timer",
	StopTimerPrefix = "SBM_Stop",
	Timer = {
		Timers = {},
		TimersSorted = {},
		ActiveTimers = 0,
		TimeSinceLastCheck = 0
	},
	Message = {
		Messages = {},
		ActiveMessages = 0,
		TimeSinceLastCheck = 0,
		Update = true,
	}
}

SuuBossMods.Core.Frame = CreateFrame("frame")

SuuBossMods.Info = SuuBossMods.Info or {
	Updated = true,
	Name = "SuuBossMods",
	Version = "0.1 ALPHA"
}

SuuBossMods.Core.Events = {
	"COMBAT_LOG_EVENT_UNFILTERED",
	"ENCOUNTER_START",
	"ENCOUNTER_END",
	"CHAT_MSG_ADDON",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_REGEN_DISABLED",
	"UNIT_POWER_FREQUENT",
	"UNIT_SPELLCAST_SUCCEEDED",
}

SuuBossMods.Core.Frame:SetScript("OnUpdate", function(_, renderTime)
	SuuBossMods.Core.Timer.TimeSinceLastCheck = SuuBossMods.Core.Timer.TimeSinceLastCheck + renderTime
	SuuBossMods.Core.Message.TimeSinceLastCheck = SuuBossMods.Core.Message.TimeSinceLastCheck + renderTime
	if (SuuBossMods.Core.Timer.TimeSinceLastCheck >= SuuBossMods.db.profile.core.timer.update_interval) then
		SuuBossMods.Core.UpdateTimers()
		SuuBossMods.Core.Timer.TimeSinceLastCheck = 0
		if (SuuBossMods.Core.EncounterRunning) then
			SuuBossMods.Core.EncounterDuration = GetTime() - SuuBossMods.Core.EncounterPulled
		end
	end
	
	if (SuuBossMods.Core.Message.TimeSinceLastCheck >= SuuBossMods.db.profile.core.message.update_interval) then
		if (SuuBossMods.Core.Message.Update == true) then
			SuuBossMods:UpdateMessages()
			SuuBossMods.Core.Message.TimeSinceLastCheck = 0
		end
	end
end)

SuuBossMods.Core.Frame:SetScript("OnEvent", function(_, event, ...)
	if (SuuBossMods.Core[event] ~= nil) then
		SuuBossMods.Core[event](...)
	end
	
	if (ActiveModule ~= nil and ActiveModule[event] ~= nil) then
		ActiveModule[event](ActiveModule, ...)
	end
	
	for i, Plugin in ipairs(Plugins) do
		if (Plugin[event] ~= nil) then
			Plugin[event](...)
		end
	end
end)

function SuuBossMods:GetPlugins()
	return Plugins
end

function SuuBossMods:AddPlugin(plugin)
	table.insert(Plugins, plugin)
end

function SuuBossMods:AddModule(mod)
	Modules[tostring(mod.encounterID)] = mod
end

function SuuBossMods:ChatMessage(message)
	print("|c0000FF00SuuBossMods|r: "..message)
end

function SuuBossMods:AddInitCallback(callback)
	table.insert(OnInitCallbacks, callback)
end

function SuuBossMods:RefreshConfig()
	MainBarAnchor:SetPosition(SuuBossMods.db.profile.mainbar.anchorX, SuuBossMods.db.profile.mainbar.anchorY)
	MainBarAnchor:SetWidth(SuuBossMods.db.profile.mainbar.width)
	MainBarAnchor:SetHeight(SuuBossMods.db.profile.mainbar.height)
	SoonBarAnchor:SetPosition(SuuBossMods.db.profile.soonbar.anchorX, SuuBossMods.db.profile.soonbar.anchorY)
	SoonBarAnchor:SetWidth(SuuBossMods.db.profile.soonbar.width)
	SoonBarAnchor:SetHeight(SuuBossMods.db.profile.soonbar.height)
	
	for i=0, MainBarCount - 1 do
		MainBars[i]:SetWidth(SuuBossMods.db.profile.mainbar.width)
		MainBars[i]:SetHeight(SuuBossMods.db.profile.mainbar.height)
		self:AnchorBar(MainBars,i, MainBarAnchor, SuuBossMods.db.profile.mainbar.growth_direction)
	end
	self:SetMainBarColor(SuuBossMods.db.profile.mainbar.color)
	self:SetMainBarBackgroundColor(SuuBossMods.db.profile.mainbar.background_color)
	self:SetMainBarBorderColor(SuuBossMods.db.profile.mainbar.border_color)
	
	for i=0, SoonBarCount - 1 do
		SoonBars[i]:SetWidth(SuuBossMods.db.profile.soonbar.width)
		SoonBars[i]:SetHeight(SuuBossMods.db.profile.soonbar.height)
		self:AnchorBar(SoonBars,i, SoonBarAnchor, SuuBossMods.db.profile.soonbar.growth_direction)
	end
	self:SetSoonBarColor(SuuBossMods.db.profile.soonbar.color)
	self:SetSoonBarBackgroundColor(SuuBossMods.db.profile.soonbar.background_color)
	self:SetSoonBarBorderColor(SuuBossMods.db.profile.soonbar.border_color)
	
	TimerMessageDisplay:SetPosition(SuuBossMods.db.profile.timermessagedisplay.anchorX, SuuBossMods.db.profile.timermessagedisplay.anchorY)
	TimerMessageDisplay:SetFontSize(SuuBossMods.db.profile.timermessagedisplay.size)
	TimerMessageDisplay:SetTextColor(SuuBossMods.db.profile.timermessagedisplay.color)
end

function SuuBossMods:OnInitialize()

	for i, Plugin in ipairs(SuuBossMods:GetPlugins()) do
		if (Plugin["GetDefaults"] ~= nil and Plugin.name ~= nil) then
			defaults["profile"]["plugins"][Plugin.name] = Plugin:GetDefaults()
		end
	end

	SuuBossMods.db = LibStub("AceDB-3.0"):New("SuuBossModsDB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	self:RegisterChatCommand("sbm", "SlashInput")
	self:InitEvents()
	MainBarAnchor = SBM_Bar(SuuBossMods.db.profile.mainbar.anchorX, SuuBossMods.db.profile.mainbar.anchorY, SuuBossMods.db.profile.mainbar.width,SuuBossMods.db.profile.mainbar.height,1,1)
	self:InitAnchor(MainBarAnchor)
	MainBarAnchor:SetTimerName("MainBars")
	SoonBarAnchor  = SBM_Bar(SuuBossMods.db.profile.soonbar.anchorX, SuuBossMods.db.profile.soonbar.anchorY, SuuBossMods.db.profile.soonbar.width,SuuBossMods.db.profile.soonbar.height,1,1)
	self:InitAnchor(SoonBarAnchor)
	SoonBarAnchor:SetTimerName("SoonBars")
	self:InitMainBars()
	self:InitSoonBars()	
	self:InitMessageDisplay()
	RegisterAddonMessagePrefix(SuuBossMods.Core.SendTimerPrefix);
	RegisterAddonMessagePrefix(SuuBossMods.Core.StopTimerPrefix);
	
	for i, Callback in ipairs(OnInitCallbacks) do
		Callback()
	end
	
	for i, Plugin in ipairs(Plugins) do
		Plugin:OnInit()
	end
	
end

function SuuBossMods:GetPlayerRole()
	--TODO: UPDATE DEMONHUNTER
	local playerClass = select(3,UnitClass("player"))
	local currentSpec = GetSpecialization()
	if (currentSpec == nil) then
		return "NONE"
	end
	local roles = {
		[1] = { --WARRIOR
			[1] = "MELEE",
			[2] = "MELEE",
			[3] = "TANK",
		},
		[2] = { --PALADIN
			[1] = "SEMIHEAL",
			[2] = "MELEE",
			[3] = "TANK",
		},
		[3] = { --HUNTER
			[1] = "RANGE",
			[2] = "RANGE",
			[3] = "MELEE",
		},
		[4] = { --ROGUE
			[1] = "MELEE",
			[2] = "MELEE",
			[3] = "MELEE",
		},
		[5] = { --PRIEST
			[1] = "HEAL",
			[2] = "HEAL",
			[3] = "RANGE",
		},
		[6] = { --DK
			[1] = "TANK",
			[2] = "MELEE",
			[3] = "MELEE",
		},
		[7] = { --SHAMAN
			[1] = "RANGE",
			[2] = "MELEE",
			[3] = "HEAL",
		},
		[8] = { --MAGE
			[1] = "RANGE",
			[2] = "RANGE",
			[3] = "RANGE",
		},
		[9] = { --WARLOCK
			[1] = "RANGE",
			[2] = "RANGE",
			[3] = "RANGE",
		},
		[10] = { --MONK
			[1] = "TANK",
			[2] = "SEMIHEAL",
			[3] = "MELEE",
		},
		[11] = { --DRUID
			[1] = "RANGE",
			[2] = "MELEE",
			[3] = "TANK",
			[4] = "HEAL",
		},
	}
	return roles[playerClass][currentSpec]
end

function SuuBossMods:IsTank()
	return self:GetPlayerRole() == "TANK"
end

function SuuBossMods:IsRange()
	return self:GetPlayerRole() == "RANGE"
end

function SuuBossMods:IsMelee()
	return self:GetPlayerRole() == "MELEE"
end

function SuuBossMods:IsHeal()
	return self:GetPlayerRole() == "HEAL" or self:GetPlayerRole() == "SEMIHEAL"
end

function SuuBossMods:IsSemiHeal()
	return self:GetPlayerRole() == "SEMIHEAL"
end



function SuuBossMods:StartTimer(name, duration, spellid, message, callback)
	SuuBossMods.Core.Timer.Timers[SuuBossMods.Core.Timer.ActiveTimers] = {["Name"] = name, ["Duration"] = duration, ["SpellID"] = spellid, ["StartTime"] = GetTime(),["Message"] = message, ["Callback"] = callback}
	SuuBossMods:SortTimers()
	SuuBossMods.Core.Timer.ActiveTimers = SuuBossMods.Core.Timer.ActiveTimers + 1
end

function SuuBossMods:StartTimerMessage(message)
	SuuBossMods.Core.Message.Messages[SuuBossMods.Core.Message.ActiveMessages] = {["Text"] = message.Text, ["Duration"] = message.Duration, ["StartTime"] = GetTime()}
	SuuBossMods.Core.Message.ActiveMessages = SuuBossMods.Core.Message.ActiveMessages + 1
end

function SuuBossMods:InitAnchor(anchor)
	anchor:SetVisible(false)
	anchor:SetTimerName("Anchor")
	anchor:SetTimerDuration("")
	anchor:SetSpellID(1)
end

function SuuBossMods:InitMessageDisplay()
	TimerMessageDisplay = SBM_Text("", SuuBossMods.db.profile.timermessagedisplay.anchorX,SuuBossMods.db.profile.timermessagedisplay.anchorY,SuuBossMods.db.profile.timermessagedisplay.size)
	TimerMessageDisplay:SetTextColor(SuuBossMods.db.profile.timermessagedisplay.color)
end

function SuuBossMods:InitMainBars()
	for i=0, MainBarCount - 1 do
		MainBars[i] = SBM_Bar(400, 500, SuuBossMods.db.profile.mainbar.width, SuuBossMods.db.profile.mainbar.height,1000,1000)
		MainBars[i]:SetVisible(false)
		self:AnchorBar(MainBars,i, MainBarAnchor, SuuBossMods.db.profile.mainbar.growth_direction)
	end
	self:SetMainBarColor(SuuBossMods.db.profile.mainbar.color)
	self:SetMainBarBackgroundColor(SuuBossMods.db.profile.mainbar.background_color)
	self:SetMainBarBorderColor(SuuBossMods.db.profile.mainbar.border_color)
end

function SuuBossMods:SetMainBarColor(color)
	for i=0, MainBarCount - 1 do
		MainBars[i]:SetBarColor(color.r, color.g, color.b, color.a)
	end
end

function SuuBossMods:SetMainBarBackgroundColor(color)
	for i=0, MainBarCount - 1 do
		MainBars[i]:SetBackgroundColor(color.r, color.g, color.b, color.a)
	end
end

function SuuBossMods:SetMainBarBorderColor(color)
	for i=0, MainBarCount - 1 do
		MainBars[i]:SetBorderColor(color)
	end
end

function SuuBossMods:SetSoonBarBackgroundColor(color)
	for i=0, SoonBarCount - 1 do
		SoonBars[i]:SetBackgroundColor(color.r, color.g, color.b, color.a)
	end
end

function SuuBossMods:SetSoonBarColor(color)
	for i=0, SoonBarCount - 1 do
		SoonBars[i]:SetBarColor(color.r, color.g, color.b, color.a)
	end
end

function SuuBossMods:SetSoonBarBorderColor(color)
	for i=0, SoonBarCount - 1 do
		SoonBars[i]:SetBorderColor(color)
	end
end

function SuuBossMods:InitSoonBars()
	for i=0, SoonBarCount - 1 do
		SoonBars[i] = SBM_Bar(400, 500, SuuBossMods.db.profile.soonbar.width, SuuBossMods.db.profile.soonbar.height,1000,1000)
		SoonBars[i]:SetVisible(false)
		self:AnchorBar(SoonBars,i, SoonBarAnchor, SuuBossMods.db.profile.soonbar.growth_direction)
	end
	self:SetSoonBarColor(SuuBossMods.db.profile.soonbar.color)
	self:SetSoonBarBorderColor(SuuBossMods.db.profile.soonbar.border_color)
	self:SetSoonBarBackgroundColor(SuuBossMods.db.profile.soonbar.background_color)
end

function SuuBossMods:SetMainBarWidth(width)
	SuuBossMods.db.profile.mainbar.width = width
	MainBarAnchor:SetWidth(width)
	for i=0, MainBarCount - 1 do
		MainBars[i]:SetWidth(width)
	end
end

function SuuBossMods:SetMainBarHeight(height)
	SuuBossMods.db.profile.mainbar.height = height
	MainBarAnchor:SetHeight(height)
	for i=0, MainBarCount - 1 do
		MainBars[i]:SetHeight(height)
		self:AnchorBar(MainBars,i, MainBarAnchor, SuuBossMods.db.profile.mainbar.growth_direction)
	end
end

function SuuBossMods:SetSoonBarWidth(width)
	SuuBossMods.db.profile.soonbar.width = width
	SoonBarAnchor:SetWidth(width)
	for i=0, SoonBarCount - 1 do
		SoonBars[i]:SetWidth(width)
	end
end

function SuuBossMods:SetSoonBarHeight(height)
	SuuBossMods.db.profile.soonbar.height = height
	SoonBarAnchor:SetHeight(height)
	for i=0, SoonBarCount - 1 do
		SoonBars[i]:SetHeight(height)
		self:AnchorBar(SoonBars,i, SoonBarAnchor, SuuBossMods.db.profile.soonbar.growth_direction)
	end
	
end

function SuuBossMods:SendTimer(TimerName, Duration, SpellID, Message, TargetType, Target)
    if (TargetType == "RAID") then
        SendAddonMessage(SuuBossMods.Core.SendTimerPrefix, TimerName .. "," .. Duration .. "," .. SpellID .. "," .. Message.Text .. "," .. Message.Start .. "," .. Message.Duration, "RAID");
    end
    
    if(TargetType == "WHISPER") then
         SendAddonMessage(SuuBossMods.Core.SendTimerPrefix, TimerName .. "," .. Duration .. "," .. SpellID .. "," .. Message.Text .. "," .. Message.Start .. "," .. Message.Duration, "WHISPER", Target);
    end
end

function SuuBossMods:AnchorBar(bars, index, anchor, growth_direction)
	if (growth_direction == "DOWN") then
		if (index ~= 0) then
			bars[index].LongTimerFrame:SetPoint("TOPLEFT", bars[index-1].LongTimerFrame, "BOTTOMLEFT",0,0)
		else
			bars[index].LongTimerFrame:SetPoint("TOPLEFT", anchor.LongTimerFrame, "BOTTOMLEFT",0,0)
		end
	end
	
	if (growth_direction == "UP") then
		if (index ~= 0) then
			bars[index].LongTimerFrame:SetPoint("TOPLEFT", bars[index-1].LongTimerFrame, "BOTTOMLEFT",0,bars[index-1].height * 2 + 12)
		else
			bars[index].LongTimerFrame:SetPoint("TOPLEFT", anchor.LongTimerFrame, "BOTTOMLEFT",0,anchor.height * 2 + 12)
		end
	end
end

function SuuBossMods:InitEvents()
	for i, EventToRegister in ipairs(SuuBossMods.Core.Events) do
		SuuBossMods.Core.Frame:RegisterEvent(EventToRegister)
	end
end

function SuuBossMods:SendStopTimer(spellid, TargetType, Target)
	if (TargetType == "RAID") then
        SendAddonMessage(SuuBossMods.Core.StopTimerPrefix, tostring(spellid), "RAID");
    end
    
    if(TargetType == "WHISPER") then
        SendAddonMessage(SuuBossMods.Core.StopTimerPrefix, tostring(spellid),"WHISPER", Target);
    end
end

function SuuBossMods:SlashInput(Input)
	local Options = Input
	
	if (Options == "hide minimap") then
		self:ChangeMinimapButtonVisibility()
	end
	
	if (string.match(Options, "pull")) then
		local pullValues = {}
		i = 1
		for word in Options:gmatch("%w+") do table.insert(pullValues, word) end
		local duration
			
		if pullValues[2] == nil then 
			duration = 10
		else
			duration = tonumber(pullValues[2])
		end
		
		if tonumber(duration) ~= 0 then
			self:SendTimer("Pull", duration, 100, {["Start"] = 0, ["Text"] = "PULL", ["Duration"] = 3}, "RAID")
		else
			self:SendStopTimer(100, "RAID")
		end	
	end
	
	if (string.match(Options, "break")) then
		local pullValues = {}
		i = 1
		for word in Options:gmatch("%w+") do table.insert(pullValues, word) end
		local duration
			
		if pullValues[2] == nil then 
			duration = 5
		else
			duration = tonumber(pullValues[2])
		end
		
		if tonumber(duration) ~= 0 then
			self:SendTimer("Break!", duration * 60, 19705, {["Start"] = 0, ["Text"] = "PULL", ["Duration"] = 3}, "RAID")
		else
			self:SendStopTimer(19705, "RAID")
		end	
	end	
	
	for i, Plugin in ipairs(Plugins) do
		if (Plugin["SlashInput"] ~= nil) then
			Plugin["SlashInput"](Plugin, Input)
		end
	end
end

function SuuBossMods:UnlockAnchor()
	MainBarAnchor:SetLocked(not MainBarAnchor:IsLocked())
	MainBarAnchor:SetVisible(not MainBarAnchor:IsLocked())
	SoonBarAnchor:SetLocked(not SoonBarAnchor:IsLocked())
	SoonBarAnchor:SetVisible(not SoonBarAnchor:IsLocked())
end

SuuBossMods.SPairs = function(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

SuuBossMods.SortComperator = function(t,a,b) 
    return SuuBossMods:GetRemainingTime(t, b) < SuuBossMods:GetRemainingTime(t, a)
end

function SuuBossMods:GetRemainingTime(t,i)
	return t[i].StartTime + t[i].Duration - GetTime()
end

function SuuBossMods:SortTimers()
	SuuBossMods.Core.Timer.TimersSorted = {}
    if (SuuBossMods.Core.Timer.Timers ~= nil) then
        local counter = 0
        for i, v in SuuBossMods.SPairs(SuuBossMods.Core.Timer.Timers, SuuBossMods.SortComperator) do
            if (v ~= nil) then
                SuuBossMods.Core.Timer.TimersSorted[counter] = v
                counter = counter + 1
            end
        end
    end
end

SuuBossMods.Core.UpdateTimers = function()
	local i = 0
	while i <= SuuBossMods.Core.Timer.ActiveTimers-1 do
		local remaining_time = SuuBossMods.Core.Timer.Timers[i].StartTime + SuuBossMods.Core.Timer.Timers[i].Duration - GetTime()
		
		if (SuuBossMods.Core.Timer.Timers[i].Callback ~= nil) then
			SuuBossMods.Core.Timer.Timers[i].Callback(remaining_time)
		end
		
		if (SuuBossMods.Core.Timer.Timers[i].Message ~= nil and SuuBossMods.Core.Timer.Timers[i].Message.Displayed == nil and SuuBossMods.Core.Timer.Timers[i].Message.Start >= remaining_time) then
				SuuBossMods:StartTimerMessage(SuuBossMods.Core.Timer.Timers[i].Message)
				SuuBossMods.Core.Timer.Timers[i].Message.Displayed = true
		end
			
		if (remaining_time <= 0) then
			if (SuuBossMods.Core.Timer.Timers[i].Message ~= nil and SuuBossMods.Core.Timer.Timers[i].Message.Displayed == nil) then
				SuuBossMods:StartTimerMessage(SuuBossMods.Core.Timer.Timers[i].Message)
			end
		
			for k=i, SuuBossMods.Core.Timer.ActiveTimers-2 do
				SuuBossMods.Core.Timer.Timers[k] = SuuBossMods.Core.Timer.Timers[k+1]
			end
			SuuBossMods.Core.Timer.Timers[SuuBossMods.Core.Timer.ActiveTimers-1] = nil
			SuuBossMods.Core.Timer.ActiveTimers = SuuBossMods.Core.Timer.ActiveTimers - 1
			i = i - 1
			SuuBossMods:SortTimers()
		end
		i = i + 1
	end
	SuuBossMods.UpdateBars()
end

function SuuBossMods:StopTimer(spellID)
	local i = 0
	while i <= SuuBossMods.Core.Timer.ActiveTimers-1 do
		if (SuuBossMods.Core.Timer.Timers[i].SpellID ~= nil and SuuBossMods.Core.Timer.Timers[i].SpellID == spellID) then
			for k=i, SuuBossMods.Core.Timer.ActiveTimers-2 do
				SuuBossMods.Core.Timer.Timers[k] = SuuBossMods.Core.Timer.Timers[k+1]
			end
			SuuBossMods.Core.Timer.Timers[SuuBossMods.Core.Timer.ActiveTimers-1] = nil
			SuuBossMods.Core.Timer.ActiveTimers = SuuBossMods.Core.Timer.ActiveTimers - 1
			SuuBossMods:SortTimers()
		end
		i = i + 1
	end
end

function SuuBossMods:StopTimerByName(Name)
	local i = 0
	while i <= SuuBossMods.Core.Timer.ActiveTimers-1 do
		if (SuuBossMods.Core.Timer.Timers[i].Name ~= nil and SuuBossMods.Core.Timer.Timers[i].Name == Name) then
			for k=i, SuuBossMods.Core.Timer.ActiveTimers-2 do
				SuuBossMods.Core.Timer.Timers[k] = SuuBossMods.Core.Timer.Timers[k+1]
			end
			SuuBossMods.Core.Timer.Timers[SuuBossMods.Core.Timer.ActiveTimers-1] = nil
			SuuBossMods.Core.Timer.ActiveTimers = SuuBossMods.Core.Timer.ActiveTimers - 1
			SuuBossMods:SortTimers()
		end
		i = i + 1
	end
end

function SuuBossMods:UnlockMessageAnchor()
	if (TimerMessageDisplay:IsLocked()) then
		SuuBossMods.Core.Message.Update = false
		TimerMessageDisplay:SetText("MOVE ME")		
	else
		SuuBossMods.Core.Message.Update = true
	end
	TimerMessageDisplay:SetLocked(not TimerMessageDisplay:IsLocked())
end

function SuuBossMods:UpdateMessages() 
	local i = 0
	while i <= SuuBossMods.Core.Message.ActiveMessages-1 do
		if (SuuBossMods.Core.Message.Messages[i].StartTime + SuuBossMods.Core.Message.Messages[i].Duration <= GetTime()) then
			for k=i, SuuBossMods.Core.Message.ActiveMessages-2 do
				SuuBossMods.Core.Message.Messages[k] = SuuBossMods.Core.Message.Messages[k+1]
			end
			SuuBossMods.Core.Message.Messages[SuuBossMods.Core.Message.ActiveMessages-1] = nil
			SuuBossMods.Core.Message.ActiveMessages = SuuBossMods.Core.Message.ActiveMessages - 1
			i = i - 1
		end
		i = i + 1
	end
	self:UpdateMessageDisplay()
end

function SuuBossMods:UpdateMessageDisplay()
	local DisplayText = ""
	for i=0, SuuBossMods.Core.Message.ActiveMessages - 1 do 
		if (SuuBossMods.Core.Message.Messages[i] ~= nil) then
			DisplayText = DisplayText .. SuuBossMods.Core.Message.Messages[i].Text .. "\n"
		end
	end
	TimerMessageDisplay:SetText(DisplayText)
end

function SuuBossMods:UpdateBars()
	local i = 0
	local g = 0
	for k=0, SuuBossMods.Core.Timer.ActiveTimers -1 do
		if (SuuBossMods.Core.Timer.TimersSorted[k] ~= nil) then
			local remaining_time = SuuBossMods.Core.Timer.TimersSorted[k].StartTime + SuuBossMods.Core.Timer.TimersSorted[k].Duration - GetTime()
			if (remaining_time >= SuuBossMods.db.profile.soonbar.threshold) then
				MainBars[i]:SetTimerName(SuuBossMods.Core.Timer.TimersSorted[k].Name)
				MainBars[i]:SetMaximumValue(SuuBossMods.Core.Timer.TimersSorted[k].Duration)
				MainBars[i]:SetCurrentValue(remaining_time)
				MainBars[i]:SetTimerDuration(("%.01f"):format(remaining_time))
				MainBars[i]:SetSpellID(SuuBossMods.Core.Timer.TimersSorted[k].SpellID)
				MainBars[i]:SetVisible(true)
				i = i + 1
			end
		end
		if (SuuBossMods.Core.Timer.TimersSorted[k] ~= nil) then
			local remaining_time = SuuBossMods.Core.Timer.TimersSorted[k].StartTime + SuuBossMods.Core.Timer.TimersSorted[k].Duration - GetTime()
			if (remaining_time < SuuBossMods.db.profile.soonbar.threshold) then
				SoonBars[g]:SetTimerName(SuuBossMods.Core.Timer.TimersSorted[k].Name)
				SoonBars[g]:SetMaximumValue(SuuBossMods.Core.Timer.TimersSorted[k].Duration)
				SoonBars[g]:SetCurrentValue(remaining_time)
				SoonBars[g]:SetTimerDuration(("%.01f"):format(remaining_time))
				SoonBars[g]:SetSpellID(SuuBossMods.Core.Timer.TimersSorted[k].SpellID)
				SoonBars[g]:SetVisible(true)
				g = g + 1
			end
		end
	end
	
	for j=i, MainBarCount-1 do
		MainBars[j]:SetVisible(false)
	end
	
	for j=g, SoonBarCount-1 do
		SoonBars[j]:SetVisible(false)
	end
end

function SuuBossMods:ClearTimer()
	SuuBossMods.Core.Timer.Timers = {}
	SuuBossMods.Core.Timer.TimersSorted = {}
	SuuBossMods.Core.Timer.ActiveTimers = 0
end

SuuBossMods.Core.COMBAT_LOG_EVENT_UNFILTERED = function(...) 
end

SuuBossMods.Core.CHAT_MSG_ADDON = function(...)
	local prefix, message, channel, sender = ...
    if (SuuBossMods.Core.SendTimerPrefix ~= nil and SuuBossMods.Core.SendTimerPrefix == prefix) then
        local timerValues = {}
        local i = 1
        for word in string.gmatch(message, '([^,]+)') do
            timerValues[i] = word
            i = i + 1
        end
		
		local senderValues = {}
		i = 1
		for word in string.gmatch(sender, '([^-]+)') do
            senderValues[i] = word
            i = i + 1
        end
        local timerName = timerValues[1]
        local duration = tonumber(timerValues[2])
        local spellID = tonumber(timerValues[3])
		local message = {}
		message.Text = timerValues[4]
		message.Start = tonumber(timerValues[5])
        message.Duration = tonumber(timerValues[6])
		
		if (spellID == 100) then
			SuuBossMods:StopTimer(100)
		end
		
		if (spellID == 19705) then
			SuuBossMods:StopTimer(19705)
		end
        SuuBossMods:StartTimer(timerName .. " (" .. senderValues[1] .. ")", duration, spellID, message)
    end
	
	if (SuuBossMods.Core.StopTimerPrefix ~= nil and SuuBossMods.Core.StopTimerPrefix == prefix) then
		if (message == "100") then
			SuuBossMods:ChatMessage("Pulltimer has been stoped by: " .. sender .. "!")
			SuuBossMods:StopTimer(tonumber(message))
		end
		if (message == "19705") then
			SuuBossMods:ChatMessage("Breaktimer has been stoped by: " .. sender .. "!")
			SuuBossMods:StopTimer(tonumber(message))
		end		
	end
end

SuuBossMods.Core.ENCOUNTER_START = function(...)
	local encounterID, encounterName, difficultyID, raidSize = ...
	SuuBossMods.Core.EncounterRunning = true
	SuuBossMods.Core.EncounterPulled = GetTime()
	SuuBossMods.Core.EncounterID = encounterID
	SuuBossMods.Core.EncounterName = encounterName
	SuuBossMods.Core.RaidSize = raidSize
	SuuBossMods.Core.EncounterDuration = 0
	SuuBossMods:StopTimer(100)
	SuuBossMods:ChatMessage(encounterName .. " has been pulled. Good luck!")
	if (Modules[tostring(encounterID)] ~= nil) then
		ActiveModule = Modules[tostring(encounterID)]
		ActiveModule:SetDifficulty(difficultyID)
		ActiveModule:OnEncounterEngage(difficultyID)
	else
		SuuBossMods:ChatMessage("There is no module for this encounter loaded.")
	end	
end

SuuBossMods.Core.ENCOUNTER_END = function(...)
	local encounterID, encounterName,_,_,Result = ...
    if (Result == 1) then
        SuuBossMods.Core.EncounterResult = "Success"
    else
        SuuBossMods.Core.EncounterResult = "Wipe"
    end
	
	SuuBossMods.Core.EncounterEnded = GetTime()
    SuuBossMods.Core.EncounterRunning = false
	if (Modules[tostring(encounterID)] ~= nil) then
		ActiveModule = nil
		Modules[tostring(encounterID)]:OnEncounterEnd()
		Modules[tostring(encounterID)]:Reset()
		SuuBossMods:ClearTimer()
		if (SuuBossMods.Core.EncounterResult == "Wipe") then
			SuuBossMods:StartTimer("Respawn",Modules[tostring(encounterID)].respawnTime, 83968)
		end
	end		
	
	SuuBossMods:ChatMessage("Encounter against " .. encounterName .. " has ended.")
end

function SuuBossMods:HasDebuff(unit, spellID)
	for i = 1, 40 do
		local _, _, _, _, _, _, _, _, _, _, spellId = UnitDebuff(unit, i)
		if (spellID == spellId) then
			return true
		end
	end
	return false
end

function SuuBossMods:HasBuff(unit, spellID)
	for i = 1, 40 do
		local _, _, _, _, _, duration, expires, _, _, _, spellId = UnitBuff(unit, i)
		if (spellID == spellId) then
			return true
		end
	end
	return false
end

SuuBossMods.Core.ResetEncounter = function()
	SuuBossMods.Core.EncounterRunning = false
	SuuBossMods.Core.EncounterPulled = 0
	SuuBossMods.Core.EncounterID = 0
	SuuBossMods.Core.EncounterName = ""
	SuuBossMods.Core.RaidSize = 0
	SuuBossMods.Core.EncounterDuration = 0
end