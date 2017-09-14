SuuBossMods.NewModule = {}
SuuBossMods.NewModule.__index = SuuBossMods.NewModule

setmetatable(SuuBossMods.NewModule, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function SuuBossMods.NewModule.new(_,encounterID)
	local self = setmetatable({}, SuuBossMods.NewModule)
	self.encounterID = encounterID
	self.event_callbacks = {}
	self.registered_npc = {}
	SuuBossMods:AddModule(self)
	return self
end

function SuuBossMods.NewModule:SetDifficulty(difficultyID)
	self.difficultyID = difficultyID
end

function SuuBossMods.NewModule:IsLFR()
	return true
end

function SuuBossMods.NewModule:IsMythic()
	return difficultyID == 16
end

function SuuBossMods.NewModule:IsHeroic()
	return difficultyID == 15
end

function SuuBossMods.NewModule:IsNormal()
	return difficultyID == 14
end

function SuuBossMods.NewModule:RegisterEvent(event, callback, ...)
	--self[callback](...)	
	for i, k in ipairs{...} do
		local event_callback = {}
		event_callback.event = event
		event_callback.callback = callback
		event_callback.spellID = k
		table.insert(self.event_callbacks, event_callback)
	end
end

function SuuBossMods.NewModule:Say(message)
	SendChatMessage(message, "SAY", "Common");
end

function SuuBossMods.NewModule:Yell(message)
	SendChatMessage(message, "YELL", "Common");
end

function SuuBossMods.NewModule:Whisper(target, message)
	SendChatMessage(message, "WHISPER", "Common", target);
end

function SuuBossMods.NewModule:Reset()
	self.event_callbacks = {}
	self.registered_npc = {}
end

function SuuBossMods.NewModule:COMBAT_LOG_EVENT_UNFILTERED(...)
	local _, event, _, source_guid, source_name, source_flags, source_flags2, dest_guid, dest_name, dest_flags, dest_flags2, spellID, spellName, spellSchool, auraType, amount= ...
	local combat_log_event = {}
	combat_log_event.event = event
	combat_log_event.source_guid = source_guid
	combat_log_event.source_name = source_name
	combat_log_event.dest_guid = dest_guid
	combat_log_event.dest_name = dest_name
	combat_log_event.spell_id = spellID

	for i, k in ipairs(self.event_callbacks) do
		if (k.spellID == spellID and event == k.event and event ~= "UNIT_DIED") then
			local guid_values = {}
			local j = 1
						
			for word in string.gmatch(source_guid, '([^-]+)') do
				guid_values[j] = word
				j = j + 1
			end
			
			if (guid_values[1] == "Creature") then
				for f, npc in ipairs(self.registered_npc) do
					if (tostring(guid_values[6]) == tostring(npc)) then
						combat_log_event.npc = tonumber(npc)
						self[k.callback](self, combat_log_event)
					end
				end
			end
			
		end
		
		if (event == "UNIT_DIED" and k.event == "UNIT_DIED") then
			local guid_values = {}
			local j = 1
						
			for word in string.gmatch(dest_guid, '([^-]+)') do
				guid_values[j] = word
				j = j + 1
			end

			if (k.spellID == tonumber(guid_values[6])) then
				self[k.callback](self, combat_log_event)
			end
		end
		
	end
end

function SuuBossMods:CreateCountdownCallback(name, threshold)
	return function(remaining_time)	
			if(remaining_time < threshold and remaining_time % 1 > self.curseCheck and remaining_time > 0) then	
				self:Yell(name .. " fades in " .. ("%.0f"):format(tostring(remaining_time)) .. "!")
			end
			self.curseCheck = remaining_time % 1
	end
end

function SuuBossMods.NewModule:RaidTarget(target, raidmark)
	SetRaidTarget(target,8)
end

function SuuBossMods.NewModule:IsPlayer(name)
	return UnitName("player") == name
end

function SuuBossMods.NewModule:RegisterNPC(...)
	for i, k in ipairs{...} do
		table.insert(self.registered_npc, k)
	end
end

