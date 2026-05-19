local sensorInfo = {
	name = "CTPAllGoalsSatisfied",
	desc = "Returns true if all goals of mission are satisfied, otherwise false",
	author = "Filip Doležal",
	date = "2026-05-19",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- no caching 

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

-- @description returns true if all goals of mission are satisfied, otherwise false
-- @argument info - the mission info
-- @return bool
return function(missionInfo)
    return missionInfo.areasOccupied[1] and missionInfo.areasOccupied[2] and missionInfo.areasOccupied[3] and missionInfo.areasOccupied[4] and missionInfo.score >= missionInfo.scoreForBonus
end