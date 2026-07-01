local sensorInfo = {
	name = "Get Metal",
	desc = "Returns current amount of metal",
	author = "Dolezafi",
	date = "2026-06-30",
	license = "MIT",
}

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

-- speed-ups
local UnitIsDead = Spring.GetUnitIsDead

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- @description return true if we have enough metal to purchase the given item (unit / line upgrade), false otherwise
return function()
    local teamID = Spring.GetMyTeamID()
    local currentMetal, _, _, _, _, _, _, _ = Spring.GetTeamResources(teamID, "metal")
    return currentMetal
end