local sensorInfo = {
	name = "Group",
	desc = "Returns group of units for formation custom group move",
	author = "Filip Doležal",
	date = "2026-04-18",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

return function(otherUnits)
	local group = {}
	
	for i=1, #otherUnits do
		local unitID = otherUnits[i]
        if unitID ~= nil then
    		group[unitID] = i
        end
	end
	
	return group
end