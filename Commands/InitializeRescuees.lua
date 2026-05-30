function getInfo()
    return {
        onNoUnits = SUCCESS,
        tooltip = "Initialize rescuees info.",
        parameterDefs = {
            {
                name = "rescuees",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "",
            },
            -- @parameter rescuees units [array]
        }
    }
end

function GetDistance(position1, position2)
	local diff = position1 - position2
	local dist = math.sqrt(diff.x * diff.x + diff.z * diff.z)
	return dist
end

-- Main behaviour
function Run(self, units, parameter)

    if not self.isInitialized then
        bb.rescuees = {}
        bb.rescueeOrder = {}

        for _, unitID in ipairs(parameter.rescuees or {}) do
            bb.rescuees[unitID] = "stranded" -- "stranded", "claimed", "saved", "dead"
        end

        local center = bb.missionInfo.safeArea.center

        table.sort(parameter.rescuees, function(a, b)
            local da = GetDistance(Vec3(Spring.GetUnitPosition(a)), center)
            local db = GetDistance(Vec3(Spring.GetUnitPosition(b)), center)

            return da < db
        end)

        bb.rescueeOrder = parameter.rescuees

        self.isInitialized = true
    end

    return SUCCESS
end

-- Reset behaviour state
function Reset(self)
    self.isInitialized = false
end