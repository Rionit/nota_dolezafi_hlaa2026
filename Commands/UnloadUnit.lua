function getInfo()
	return {
		onNoUnits = SUCCESS,
		tooltip = "Unload given unit",
		parameterDefs = {
			{
				name = "transporter",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = ""
			},
			{
				name = "unit",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = ""
			}
		}
	}
end

-- local shortcuts for performance
local GiveOrderToUnit = Spring.GiveOrderToUnit
local ValidUnitID = Spring.ValidUnitID
local UnitIsDead = Spring.GetUnitIsDead
local GetUnitTransporter = Spring.GetUnitTransporter
local GetUnitDefID = Spring.GetUnitDefID
local GetGroundHeight = Spring.GetGroundHeight

local GRID = 100

local function IsInvalid(id)
	return (id == nil) or (not ValidUnitID(id))
end

local function IsDead(id)
	local dead = UnitIsDead(id)
	return dead == true or dead == nil
end

-- pick random free position in safe area (snapped to grid)
local function GetUnloadPosition(area)
	bb.unloadedPositions = bb.unloadedPositions or {}

	for i = 1, 25 do
		local angle = math.random() * math.pi * 2
		local dist = math.random() * (area.radius - 50)

		local x = area.center.x + math.cos(angle) * dist
		local z = area.center.z + math.sin(angle) * dist

		-- snap to grid (modulo 5 style)
		x = math.floor(x / GRID + 0.5) * GRID
		z = math.floor(z / GRID + 0.5) * GRID

		local y = GetGroundHeight(x, z)
		local key = x .. "_" .. z

		if not bb.unloadedPositions[key] then
			bb.unloadedPositions[key] = true
			return { x = x, y = y, z = z }
		end
	end

	return nil
end

function Run(self, units, parameter)
	local carrier = parameter.transporter
	local target = parameter.unit

	if IsInvalid(carrier) or IsInvalid(target) then
		return FAILURE
	end

	if not self.isInitialized then

		local def = GetUnitDefID(carrier)
		if def and UnitDefs[def] and not UnitDefs[def].isTransport then
			return FAILURE
		end

		if GetUnitTransporter(target) ~= carrier then
			return FAILURE
		end

		local pos = GetUnloadPosition(bb.missionInfo.safeArea)
		if not pos then
			return FAILURE
		end

		self.pos = pos

		-- 1. move to unload position (shift queued)
		GiveOrderToUnit(
			carrier,
			CMD.MOVE,
			{ pos.x, pos.y, pos.z },
			{  }
		)

		-- 2. wait 3 seconds using TIMEWAIT (shift queued)
		-- Seems like this command does nothing, but it works
		-- even without it and units don't slide anymore
		-- GiveOrderToUnit(
		-- 	carrier,
		-- 	CMD.TIMEWAIT,
		-- 	{ 3000 },
		-- 	{ "shift" }
		-- )

		-- 3. unload unit at position (shift queued)
		GiveOrderToUnit(
			carrier,
			CMD.UNLOAD_UNIT,
			{ pos.x, pos.y, pos.z },
			{ "shift" }
		)

		self.isInitialized = true
	end

	if IsDead(carrier) then
		bb.transporters[carrier].state = "dead"
		bb.rescuees[target] = "dead"
		return FAILURE
	end

	if GetUnitTransporter(target) == nil then
		if bb.transporters and bb.transporters[carrier] then
			bb.transporters[carrier].state = "idle"
		end
		if bb.rescuees and bb.rescuees[target] then
			bb.rescuees[target] = "saved"
		end
		return SUCCESS
	end

	return RUNNING
end

function Reset(self)
	self.isInitialized = false
	self.pos = nil
end