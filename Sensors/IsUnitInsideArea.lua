local sensorInfo = {
	name = "IsUnitInsideArea",
	desc = "Returns true/false if a unit is inside of a specified area.",
	author = "Filip Doležal",
	date = "2026-05-29",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- instant, no caching

local GetUnitPosition = Spring.GetUnitPosition

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

-- @description Returns true/false if a unit is inside of a specified area. Takes arguments unit [unitID] and area [area].
return function(unit, area)
    if not unit or 
       not area or
       not area.center or 
       not area.radius or
       unit == nil or
       area == nil
       then
		return false
	end

	local x, y, z = GetUnitPosition(unit)
	if not x or not z then
		return false
	end

	local dx = x - area.center.x
	local dz = z - area.center.z

	return (dx * dx + dz * dz) <= (area.radius * area.radius)
end