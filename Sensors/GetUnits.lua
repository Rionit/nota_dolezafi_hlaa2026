local sensorInfo = {
	name = "GetUnits",
	desc = "Returns array of units that are not dead",
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

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speed-ups
local GetTeamUnits = Spring.GetTeamUnits
local GetMyTeamID = Spring.GetMyTeamID
local GetUnitDefID = Spring.GetUnitDefID
local UnitIsDead = Spring.GetUnitIsDead
local ValidUnitID = Spring.ValidUnitID

return function(units)
    local result = {}

    for i = 1, #units do
        local unitID = units[i]

        if unitID and Spring.ValidUnitID(unitID) then
            local dead = Spring.GetUnitIsDead(unitID)
            if not dead then
                result[#result + 1] = unitID
            end
        end
    end

    if #result == 0 then
        return nil
    end

    return result
end