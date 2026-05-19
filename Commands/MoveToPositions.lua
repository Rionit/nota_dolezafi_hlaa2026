function getInfo()
	return {
		onNoUnits = SUCCESS,
		tooltip = "Moves all units to specified positions. Positions is an Array of Vec3 positions. Each unit moves to positions[i]",
		parameterDefs = {
			{ 
                -- Array of Vec3 positions - each unit moves to positions[i]
				name = "positions", 
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
		}
	}
end

function Run(self, units, parameter)
	
    local isRunning = false

    for i = 1, #units do
        local destination = parameter.positions[i]
        local unitPosition = Vec3(Spring.GetUnitPosition(units[i]))
        
        if unitPosition:Distance(destination) > 5 then
            Spring.GiveOrderToUnit(units[i], CMD.MOVE, {destination.x, destination.y, destination.z}, {})
            isRunning = true -- we still have someone walking to their destination
        end
    end

    -- RUNNING while units are moving, SUCCESS once all arrived
	return isRunning and RUNNING or SUCCESS
end
