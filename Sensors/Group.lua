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

return function(leaderID)
    local groupMap = {}
    local index = 1
	groupMap[leaderID] = 1 	-- should work without this since I'm using Roles
							-- but for some reason leader then shares
							-- the same place with peewee on index = 2

    for _, unitID in ipairs(units) do
        if unitID ~= leaderID then
            groupMap[unitID] = index
            index = index + 1
        end
    end

    return groupMap
end