local sensorInfo = {
	name = "GetRescuePair",
	desc = "Get a pair of transporter unitID and rescuee unitID as a table { transporter, rescuee }",
	author = "Filip Doležal",
	date = "2026-05-28",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

-- @description return a pair of transporter unitID and rescuee unitID as a table { transporter, rescuee }.
-- Has one parameter closestFirst - if true, returns closest rescuee to safeArea, otherwise the furthest
return function(closestFirst)

    local rescuePair = {
        transporter = nil,
        rescuee = nil,
    }

    if bb.transporters == nil or bb.rescuees == nil or 
       bb.pathsToUnits == nil or bb.reversePathsToUnits == nil or
       bb.rescueeOrder == nil then
        return rescuePair
    end

    -- collect idle transporters
    local idleTransporters = {}
    for transporterUnitID, transporterData in pairs(bb.transporters) do
        if transporterData.state == "idle" then
            table.insert(idleTransporters, transporterUnitID)
        end
    end

    if #idleTransporters == 0 then
        return rescuePair
    end

    -- pick a random idle transporter
    local transporterUnitID = idleTransporters[math.random(#idleTransporters)]

    -- determine iteration order
    local order = bb.rescueeOrder
    local startIdx, endIdx, step

    if closestFirst == false then
        startIdx = #order
        endIdx = 1
        step = -1
    else
        startIdx = 1
        endIdx = #order
        step = 1
    end

    for i = startIdx, endIdx, step do
        local rescueeUnitID = order[i]
        local status = bb.rescuees[rescueeUnitID]

        if status == "stranded" and bb.pathsToUnits[rescueeUnitID] ~= nil then

            bb.rescuees[rescueeUnitID] = "claimed"
            bb.transporters[transporterUnitID].state = "rescuing"
            bb.transporters[transporterUnitID].rescueeUnitID = rescueeUnitID

            rescuePair.transporter = transporterUnitID
            rescuePair.rescuee = rescueeUnitID

            return rescuePair
        end
    end

    return rescuePair
end