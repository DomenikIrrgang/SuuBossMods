local EncounterTimer = {}
EncounterTimer.name = "EncounterTimer"

SuuBossMods:AddGadget(EncounterTimer)

--local Display = SBM_Text("test", 0,0,30)

EncounterTimer.frame = CreateFrame("frame")
EncounterTimer.frame:SetScript("OnUpdate", function(_, renderTime)
	
end)

function EncounterTimer:OnInit()
	--SuuBossMods:ChatMessage("EncounterTimer init.")
end
