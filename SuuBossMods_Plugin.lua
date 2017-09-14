SuuBossMods.NewPlugin = {}
SuuBossMods.NewPlugin.__index = SuuBossMods.NewPlugin

setmetatable(SuuBossMods.NewPlugin, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function SuuBossMods.NewPlugin.new(_, name)
	local self = setmetatable({}, SuuBossMods.NewPlugin)
	self.name = name
	SuuBossMods:AddPlugin(self)
	return self
end

