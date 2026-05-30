function getInfo()
	return {
		onNoUnits = SUCCESS,
		tooltip = "Load given unit",
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

local function IsInvalid(id)
	return (id == nil) or (not ValidUnitID(id))
end

local function IsDead(id)
	local dead = UnitIsDead(id)
	return dead == true or dead == nil
end

function Run(self, units, parameter)
	local carrier = parameter.transporter
	local target = parameter.unit

	if IsInvalid(carrier) or IsInvalid(target) then
		Logger.warn("nota_dolezafi_hlaa.LoadUnit", "Transport or rescuee is not valid unit")
		return FAILURE
	end

	if not self.isInitialized then
		-- make sure carrier is actually a transport-type unit
		local def = GetUnitDefID(carrier)
		if def and UnitDefs[def] and not UnitDefs[def].isTransport then
			Logger.warn("nota_dolezafi_hlaa.LoadUnit", "Carrier is not transport type unit")
			return FAILURE
		end
		
		-- unit should not be already being transported
		if GetUnitTransporter(target) ~= nil then
			Logger.warn("nota_dolezafi_hlaa.LoadUnit", "Unit is already being transported")
			return FAILURE
		end
		
		Spring.GiveOrderToUnit(carrier, CMD.LOAD_UNITS, { target }, { "shift" })
		self.isInitialized = true
	end
	
	if IsDead(carrier) then
		Logger.warn("nota_dolezafi_hlaa.LoadUnit", "Transporter or rescuee is dead")
		bb.transporters[carrier].state = "dead"
		bb.rescuees[target] = "dead"
		return FAILURE
	end
	
	if Spring.GetUnitTransporter(target) ~= nil then
		return SUCCESS
	end

	return RUNNING
end

function Reset(self)
	self.isInitialized = false
end