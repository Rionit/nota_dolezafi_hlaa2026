local sensorInfo = {
	name = "UpdateUnitCounts",
	desc = "Updates counts of available units divided into categories.",
	author = "Dolezafi",
	date = "2026-06-30",
	license = "MIT",
}

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = -1

-- speed-ups
local UnitIsDead = Spring.GetUnitIsDead

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

function GetDistance(position1, position2)
	local diff = position1 - position2
	local dist = math.sqrt(diff.x*diff.x + diff.z*diff.z)
	return dist
end

-- @description update counts of available units divided into categories
return function()
    -- count the Atlases
    local available = 0
    for _, atlasID in ipairs(bb.units.atlases) do
        local status = bb.units.status[atlasID]
        -- if there is an available Atlas
        if status ~= "dead" then available = available + 1 end
    end
    bb.unitCounts.atlases = available

    local unitsReady = 0  -- also count units ready for attack

    -- count the available Infiltrators
    available = 0
    for _, spyID in ipairs(bb.units.infiltrators) do
        local status = bb.units.status[spyID]
        if status ~= "dead" then
            if status == "ready" then
                unitsReady = unitsReady + 1
            end
            available = available + 1
        end
    end
    bb.unitCounts.infiltrators = available

    -- count the available Seers
    available = 0
    for _, seerID in ipairs(bb.units.seers) do
        local status = bb.units.status[seerID]
        if status ~= "dead" then
            if status == "ready" then
                unitsReady = unitsReady + 1
            end
            available = available + 1
        end
    end
    bb.unitCounts.seers = available

    -- count the available Farks
    available = 0
    for _, farkID in ipairs(bb.units.farks) do
        local status = bb.units.status[farkID]
        if status ~= "dead" then
            if status == "ready" then
                unitsReady = unitsReady + 1
            end
            available = available + 1
        end
    end
    bb.unitCounts.farks = available

    -- count the available Boxes
    available = 0
    for _, spyID in ipairs(bb.units.boxes) do
        local status = bb.units.status[spyID]
        if status ~= "dead" then
            if status == "ready" then
                unitsReady = unitsReady + 1
            end
            available = available + 1
        end
    end
    bb.unitCounts.boxes = available

    -- count available Mavericks
    available = 0
    for _, mavID in ipairs(bb.units.mavericks) do
        local status = bb.units.status[mavID]
        if status ~= "dead" then
            if status == "ready" then
                unitsReady = unitsReady + 1
            end
            available = available + 1
        end
    end
    bb.unitCounts.mavericks = available

    -- count available Lugers
    available = 0
    for _, lugID in ipairs(bb.units.lugers) do
        local status = bb.units.status[lugID]
        if status ~= "dead" then
            if status == "ready" then
                unitsReady = unitsReady + 1
            end
            available = available + 1
        end
    end
    bb.unitCounts.lugers = available

    bb.unitCounts.ready = unitsReady
    
    return nil
end