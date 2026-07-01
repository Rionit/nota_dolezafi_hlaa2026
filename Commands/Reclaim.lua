function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Reclaim metal in a certain area",
		
		parameterDefs = 
		{
			{ 
				name = "units",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = ""
			},
			{ 
				name = "center",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = ""
			},
			{ 
				name = "radius",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = ""
			}
		}
	}
end

function GetCorpses(center, radius)
    features = Spring.GetFeaturesInSphere(center.x, center.y, center.z, radius)
    local corpses = 0
    for i = 1, #features do
        if Spring.GetFeatureResources(features[i]) > 0 then 
            corpses = corpses + 1
        end
    end
	return corpses
end

function Run(self, units, parameter)
	
	units = parameter.units
	center = parameter.center
	radius = parameter.radius
	
	if GetCorpses(center, radius) == 0 then 
		return SUCCESS
	end
	
	for i = 1, #units do
		Spring.GiveOrderToUnit(units[i], CMD.RECLAIM, {center.x, center.y, center.z, radius}, {})
	end

	return RUNNING
end