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
			},
						{ 
				name = "position",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
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

function Run(self, units, parameter)
	local transporter = parameter.transporter
	local unit = parameter.unit
	local position = parameter.position

	if IsInvalid(transporter) or IsInvalid(unit) then
		return FAILURE
	end

	if not self.isInitialized then

		local def = GetUnitDefID(transporter)
		if def and UnitDefs[def] and not UnitDefs[def].isTransport then
			return FAILURE
		end

		if not ValidUnitID(unit) or not ValidUnitID(transporter) then
            return FAILURE
        end

		if GetUnitTransporter(unit) ~= transporter then
			return FAILURE
		end

		-- 1. move to unload position (shift queued)
		GiveOrderToUnit(
			transporter,
			CMD.MOVE,
			{ position.x, position.y, position.z },
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
			transporter,
			CMD.UNLOAD_UNIT,
			{ position.x, position.y, position.z },
			{ "shift" }
		)

		self.isInitialized = true
	end

	if GetUnitTransporter(unit) == nil then
        return SUCCESS
    end

	local unitIsDead = UnitIsDead(transporter)
    if unitIsDead == true or unitIsDead == nil then
        return FAILURE
    end
    unitIsDead = UnitIsDead(unit)
    if unitIsDead == true or unitIsDead == nil then
        return FAILURE
    end

	return RUNNING
end

function Reset(self)
	self.isInitialized = false
end