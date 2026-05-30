function getInfo()
    return {
        tooltip = "Initialize transporters info.",
        parameterDefs = {
            {
                name = "transporters",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "",
            },
            -- @parameter transporter units [array]
        }
    }
end

local GiveOrderToUnit = Spring.GiveOrderToUnit

-- Main behaviour
function Run(self, units, parameter)

    if not self.isInitialized then
        bb.transporters = {}

        for _, unitID in ipairs(parameter.transporters or {}) do
            bb.transporters[unitID] = {
                state = "idle", -- "idle", "rescuing", "dead"
                rescueeUnitID = -1
            }
            GiveOrderToUnit(unitID, CMD.IDLEMODE, {0}, {})
        end

        return SUCCESS
    end

    return SUCCESS
end

-- Reset behaviour state
function Reset(self)
    self.isInitialized = false
end