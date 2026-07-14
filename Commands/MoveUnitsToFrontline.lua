function getInfo()
	return {
		onNoUnits = SUCCESS,
		tooltip = "Move the given units to the given position.",
		parameterDefs = {
			{
				name = "units",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "bb.units.",
			},
			-- @parameter units - table of unitIDs
			{
				name = "frontline",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "bb.frontline",
			},
			-- @parameter frontline - Vec3 of frontline to move to
			{
                name = "attack_perp_vector",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "attackVectorPerp",
			},
            -- @parameter attack_perp_vector - perp vector to attack vector
            {
                name = "fight",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "true",
			},
			{
				name = "tolerance",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "5",
			},
            {
				name = "spacing",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "100",
			},
		}
	}
end

function GetDistance(position1, position2)
	local diff = position1 - position2
	return math.sqrt(diff.x * diff.x + diff.z * diff.z)
end

local UnitIsDead = Spring.GetUnitIsDead
local GetUnitPosition = Spring.GetUnitPosition
local GiveOrderToUnit = Spring.GiveOrderToUnit
local GetUnitDefID = Spring.GetUnitDefID
local GetUnitTeam = Spring.GetUnitTeam
local ValidUnitID = Spring.ValidUnitID

function Run(self, units, parameter)
	local unitList = parameter.units
	local position = parameter.frontline
	local tolerance = parameter.tolerance
	local attackVectorPerp = parameter.attack_perp_vector
	local spacing = parameter.spacing
	local fight = parameter.fight
	local enemyUnits = Sensors.core.EnemyUnits()

	if type(unitList) ~= "table" then
		unitList = { unitList }
	end

	-- clamp target position once
	if position.x < 0 then position.x = 0 end
	if position.x > Game.mapSizeX then position.x = Game.mapSizeX end
	if position.z < 0 then position.z = 0 end
	if position.z > Game.mapSizeZ then position.z = Game.mapSizeZ end

	self.last_position = self.last_position or {}
	self.frames_without_movement = self.frames_without_movement or {}
	self.initialized = self.initialized or {}

	for i = 1, #unitList do
		local unitID = unitList[i]

		if not self.initialized[unitID] then
			if not ValidUnitID(unitID) then
				return FAILURE
			end

			local ux, uy, uz = GetUnitPosition(unitID)
			self.last_position[unitID] = Vec3(ux or 0, uy or 0, uz or 0)

			self.frames_without_movement[unitID] = 0
			self.initialized[unitID] = true
		end
	end

	local all_done = true

	for i = 1, #unitList do
		local unitID = unitList[i]

		if UnitIsDead(unitID) then
			return FAILURE
		end

		local ux, uy, uz = GetUnitPosition(unitID)
		local unitPos = Vec3(ux, uy, uz)

		local diff = position - unitPos
		local dist = math.sqrt(diff.x * diff.x + diff.z * diff.z)

		if dist >= tolerance then
			all_done = false

			local lastPos = self.last_position[unitID] or unitPos
			local moveDist = GetDistance(unitPos, lastPos)

			if moveDist < 0.01 then
				self.frames_without_movement[unitID] = (self.frames_without_movement[unitID] or 0) + 1
				if self.frames_without_movement[unitID] > 50 then
					return FAILURE
				end
			else
				self.last_position[unitID] = unitPos
				self.frames_without_movement[unitID] = 0
			end

			-- spacing along perpendicular vector
			local index = i - 1
			local offset = (index - (#unitList - 1) * 0.5) * spacing

			local targetX = position.x + attackVectorPerp.x * offset
			local targetZ = position.z + attackVectorPerp.z * offset

            local cmdID = fight and CMD.FIGHT or CMD.MOVE
			if fight then
				local weaponRange = WeaponDefs[UnitDefs[GetUnitDefID(unitID)].weapons[1].weaponDef].range
				local enemies = Spring.GetUnitsInSphere(targetX, position.y, targetZ, weaponRange)
				for i = 1, #enemies do
					local enemyID = enemies[i]
					local enemyDefID = GetUnitDefID(enemyID)

					if ValidUnitID(enemyID) 
					   and not UnitIsDead(enemyID) 
					   and enemyDefID
					   and UnitDefs[enemyDefID]
					   and (UnitDefs[enemyDefID].name == "shika" or UnitDefs[enemyDefID].name == "corvipe")
					   and GetUnitTeam(enemyID) == bb.missionInfo.battleLines.EvilMiddle.teamID
					   and (Vec3(GetUnitPosition(enemyID) - GetUnitPosition(unitID))):Length() < weaponRange then
							GiveOrderToUnit(unitID, CMD.FIRE_STATE, { 0 }, {})
							GiveOrderToUnit(unitID, CMD.ATTACK, { enemyID }, {})
							return RUNNING
					end
				end
				GiveOrderToUnit(unitID, CMD.FIRE_STATE, { 2 }, {})
				GiveOrderToUnit(unitID, cmdID, { targetX, position.y, targetZ }, {})
			else
				local cmdQueue = Spring.GetCommandQueue(unitID, 1)

				if cmdQueue and #cmdQueue > 0 and cmdQueue[1].id == CMD.MOVE then
					Spring.GiveOrderToUnit(unitID, CMD.REMOVE, { cmdQueue[1].tag }, {})
				end
				Spring.GiveOrderToUnit(
					unitID,
					CMD.INSERT,
					{
						0,                  -- insert at end of queue
						cmdID,              -- command to insert
						0,                  -- inserted command options
						targetX,
						position.y,
						targetZ
					},
					{ "alt" }              
				)
			end
		end
	end

	if all_done then
		return SUCCESS
	end

	return RUNNING
end

function Reset(self)
	self.last_position = nil
	self.frames_without_movement = nil
	self.initialized = nil
end