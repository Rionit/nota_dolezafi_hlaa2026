function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Move the given unit along the given path in the chosen direction.",
		parameterDefs = {
			{ 
				name = "unitID",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			-- @parameter unitID - unitID of the unit to move
			{ 
				name = "path",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			-- @parameter path [array] - an array of points
			{ 
				name = "reversed",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "false",
			},
			-- @parameter reversed [bool] - direction of the path
			{ 
				name = "tolerance",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "5",
			},
			-- @parameter tolerance [number] - how close to each point the unit should be
		}
	}
end

-- speed-ups
local GiveOrderToUnit = Spring.GiveOrderToUnit
local GetUnitPosition = Spring.GetUnitPosition
local UnitIsDead = Spring.GetUnitIsDead
local UnitIsValid = Spring.ValidUnitID

local function GetDistanceToTarget(self)
	local unit_position = Vec3(GetUnitPosition(self.unitID))

	local target_position = self.path[self.reversed and 1 or #self.path]

	local dx = target_position.x - unit_position.x
	local dz = target_position.z - unit_position.z

	return math.sqrt(dx * dx + dz * dz)
end

function Run(self, units, parameter)

	-- initialize once
	if not self.isInitialized then
		self.path = parameter.path          -- array
		self.unitID = parameter.unitID      -- unitID
		self.reversed = parameter.reversed  -- bool
		self.tolerance = parameter.tolerance-- number  

		if self.path == nil then
            Logger.warn("nota_dolezafi_hlaa.FollowPath", "The path is nil.")
            return FAILURE
        end

		if not UnitIsValid(self.unitID) then
            Logger.warn("nota_dolezafi_hlaa.FollowPath", "The unitID is not valid.")
            return FAILURE
        end

		if self.reversed ~= true and self.reversed ~= false then
            Logger.warn("nota_dolezafi_hlaa.FollowPath", "The bool thing is bullshit.")
            return FAILURE
        end

		-- give order while pressing SHIFT to stack orders
		for i = 1, #self.path do
			local p = self.reversed and (#self.path - i + 1) or i
			GiveOrderToUnit(self.unitID, CMD.MOVE, self.path[p]:AsSpringVector(), {"shift"})			
		end

		self.isInitialized = true
	end

	unitIsDead = UnitIsDead(self.unitID)
    if unitIsDead == true or unitIsDead == nil then
		local rescueeUnitID = bb.transporters[self.unitID].rescueeUnitID
		bb.transporters[self.unitID].state = "dead"
		bb.rescuees[rescueeUnitID] = self.reversed and "dead" or "stranded"
        return FAILURE
    end

	-- check completion
	if GetDistanceToTarget(self) < self.tolerance then
		return SUCCESS
	end

	return RUNNING
end

function Reset(self)
	self.isInitialized = false
end