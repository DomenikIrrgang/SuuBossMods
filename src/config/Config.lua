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