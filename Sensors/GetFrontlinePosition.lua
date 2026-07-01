local sensorInfo = {
	name = "GetFrontlinePosition",
	desc = "Returns the frontline position",
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
local GetTeamUnits = Spring.GetTeamUnits
local GetUnitTeam = Spring.GetUnitTeam
local GetMyTeamID = Spring.GetMyTeamID
local GetUnitDefID = Spring.GetUnitDefID
local UnitIsDead = Spring.GetUnitIsDead
local ValidUnitID = Spring.ValidUnitID
local GetUnitPosition = Spring.GetUnitPosition

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

local function average(tbl)
	if #tbl == 0 then
		return nil
	end

	local sum = 0
	for i = 1, #tbl do
		sum = sum + tbl[i]
	end
	return sum / #tbl
end

return function(linePositions, lineTeamID, lineEnemyID, badStrongPoints)
	local teamUnits = GetTeamUnits(lineTeamID)
	local enemyUnits = Sensors.core.EnemyUnits()

	local lineStart = linePositions[1]
	local lineEnd = linePositions[#linePositions]

	if badStrongPoints == 6 then
		return lineEnd
	end

	local sx, sz = lineStart.x, lineStart.z
	local ex, ez = lineEnd.x, lineEnd.z

	local lineLength = math.sqrt((ex - sx) * (ex - sx) + (ez - sz) * (ez - sz))
	if lineLength == 0 then
		return {
			x = sx,
			y = 0,
			z = sz,
		}
	end

	local teamDistances = {}
	local enemyDistances = {}
	local furthestTeamDist = 0

	-- Furthest 5 friendly units
	for i = 1, #teamUnits do
		local unitID = teamUnits[i]
		if ValidUnitID(unitID) and not UnitIsDead(unitID) then
			local ux, _, uz = GetUnitPosition(unitID)
			if ux then
				local dist = math.sqrt((ux - sx) * (ux - sx) + (uz - sz) * (uz - sz))
				teamDistances[#teamDistances + 1] = dist
				if dist > furthestTeamDist then
					furthestTeamDist = dist
				end
			end
		end
	end

	table.sort(teamDistances, function(a, b)
		return a > b
	end)

	local furthest = {}
	for i = 1, math.min(5, #teamDistances) do
		furthest[#furthest + 1] = teamDistances[i]
	end

	-- Closest 5 visible enemies from the specified enemy team
	for i = 1, #enemyUnits do
		local unitID = enemyUnits[i]
		if ValidUnitID(unitID)
			and not UnitIsDead(unitID)
			and GetUnitTeam(unitID) == lineEnemyID
		then
			local ux, _, uz = GetUnitPosition(unitID)
			if ux then
				local dist = math.sqrt((ux - sx) * (ux - sx) + (uz - sz) * (uz - sz))
				enemyDistances[#enemyDistances + 1] = dist
			end
		end
	end

	-- If no enemies are visible, return the furthest friendly position + some bit.
	if #enemyDistances == 0 then
		local t = math.min(furthestTeamDist / lineLength, 1)
		return {
			x = sx + (ex - sx) * t + 100,
			y = 0,
			z = sz + (ez - sz) * t + 100,
		}
	end

	table.sort(enemyDistances)

	local closest = {}
	for i = 1, math.min(2, #enemyDistances) do
		closest[#closest + 1] = enemyDistances[i]
	end

	local avgTeam = average(furthest) or 0
	local avgEnemy = average(closest)

	local frontlineDist = (avgTeam + avgEnemy) * 0.5
	local t = math.min(math.max(frontlineDist / lineLength, 0), 1)

	return {
		x = sx + (ex - sx) * t,
		y = 0,
		z = sz + (ez - sz) * t,
	}
end