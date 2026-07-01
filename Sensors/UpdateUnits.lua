local sensorInfo = {
	name = "UpdateUnits",
	desc = "Updates status of units filtered by category into Atlases, Mavericks, Boxes, Lugers, Infiltrators and others.",
	author = "Dolezafi",
	date = "2026-06-30",
	license = "MIT",
}

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speed-ups
local GetTeamUnits = Spring.GetTeamUnits
local GetMyTeamID = Spring.GetMyTeamID
local GetUnitDefID = Spring.GetUnitDefID
local UnitIsDead = Spring.GetUnitIsDead
local ValidUnitID = Spring.ValidUnitID
local GiveOrderToUnit = Spring.GiveOrderToUnit

-- remove dead/invalid units from all groups
local function RemoveUnitFromGroups(unitsGroups, unitID)
    local groups = {
        unitsGroups.atlases,
        unitsGroups.lugers,
        unitsGroups.mavericks,
        unitsGroups.infiltrators,
        unitsGroups.boxes,
        unitsGroups.seers,
        unitsGroups.farks,
        unitsGroups.armmarts,
        unitsGroups.others,
    }

    for _, group in ipairs(groups) do
        if group then
            for i = #group, 1, -1 do
                if group[i] == unitID then
                    table.remove(group, i)
                    break
                end
            end
        end
    end

    unitsGroups.status[unitID] = nil
end

-- @description update status of units filtered by category into Atlases, Mavericks, Lugers, Infiltrators and others
return function(unitsGroups)
    -- get all of our units
    local allUnits = GetTeamUnits(GetMyTeamID())

    -- filter the units according to the category
    for i = 1, #allUnits do
        local unitID = allUnits[i]
        if unitsGroups.status[unitID] == nil then  -- a newly purchased unit needs to be assigned to a category
            local unitDefID = GetUnitDefID(unitID)
            local name = UnitDefs[unitDefID].name
            if name == "armatlas" then
                unitsGroups.atlases[#unitsGroups.atlases+1] = unitID
                unitsGroups.status[unitID] = "available"
                GiveOrderToUnit(unitID, CMD.IDLEMODE, {0}, {})
            elseif name == "armmart" then
                unitsGroups.lugers[#unitsGroups.lugers+1] = unitID
                unitsGroups.status[unitID] = "spawned"
                GiveOrderToUnit(unitID, CMD.MOVE_STATE, {2}, {})
            elseif name == "armmav" then
                unitsGroups.mavericks[#unitsGroups.mavericks+1] = unitID
                unitsGroups.status[unitID] = "spawned"
                GiveOrderToUnit(unitID, CMD.MOVE_STATE, {0}, {})
            elseif name == "armspy" then
                unitsGroups.infiltrators[#unitsGroups.infiltrators+1] = unitID
                unitsGroups.status[unitID] = "spawned"
            elseif name == "armbox" then
                unitsGroups.boxes[#unitsGroups.boxes+1] = unitID
                unitsGroups.status[unitID] = "spawned"
                GiveOrderToUnit(unitID, CMD.MOVE_STATE, {2}, {})
            elseif name == "armseer" then
                unitsGroups.seers[#unitsGroups.seers+1] = unitID
                unitsGroups.status[unitID] = "spawned"
            elseif name == "armfark" then
                unitsGroups.farks[#unitsGroups.farks+1] = unitID
                unitsGroups.status[unitID] = "spawned"
            else
                unitsGroups.others[#unitsGroups.others+1] = unitID
                unitsGroups.status[unitID] = "spawned"
                -- Logger.warn("nota_dolezafi_UpdateUnits", "The unit [" .. unitID .. "] with name [" .. name .. "] is other.")
            end
        else  -- for older units check if they are alive

        end
    end

    for unitID, _ in pairs(unitsGroups.status) do
        if not ValidUnitID(unitID) then
            unitsGroups.status[unitID] = "dead"
        end
        local unitIsDead = UnitIsDead(unitID)
        if unitIsDead == true or unitIsDead == nil then
            unitsGroups.status[unitID] = "dead"
        end
        if unitsGroups.status[unitID] == "dead" then
            RemoveUnitFromGroups(unitsGroups, unitID)
        end
    end
    
    return nil
end