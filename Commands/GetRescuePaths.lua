function getInfo()
    return {
        tooltip = "Compute rescue paths for all units using a single BFS pass over the safe grid.",
        parameterDefs = {
            {
                name = "safeArea",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "",
            },
            -- @parameter safeArea [table]
            {
                name = "unitsToRescue",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "",
            },
            -- @parameter unitsToRescue [array]
        }
    }
end

-- speed-ups
local GetUnitPosition = Spring.GetUnitPosition

local floor = math.floor
local max = math.max
local huge = math.huge

local insert = table.insert
local remove = table.remove

-- shared neighbor offsets
local CARDINAL_NEIGHBORS = {
    { 1,  0},
    {-1,  0},
    { 0,  1},
    { 0, -1},
}

local SEARCH_OFFSETS = {
    { 1,  0}, {-1,  0},
    { 0,  1}, { 0, -1},
    { 1,  1}, { 1, -1},
    {-1,  1}, {-1, -1},
}

local function GetSafePoint(x, z)
    local column = bb.safePoints[x]
    return column and column[z]
end

-- Find closest valid safe point on the grid
local function GetClosestSafePoint(position)
    local step = bb.safePointsStep

    -- cell directly below position
    local baseX = floor(position.x / step) + 1
    local baseZ = floor(position.z / step) + 1

    -- exact hit
    if GetSafePoint(baseX, baseZ) then
        return Vec3(baseX, 0, baseZ)
    end

    -- search outward
    for radius = 1, 10 do
        for i = 1, #SEARCH_OFFSETS do
            local offset = SEARCH_OFFSETS[i]

            local x = baseX + offset[1] * radius
            local z = baseZ + offset[2] * radius

            if GetSafePoint(x, z) then
                return Vec3(x, 0, z)
            end
        end
    end

    -- fallback
    return Vec3(baseX, 0, baseZ)
end

-- Reset all BFS metadata on safe points
local function ResetSafePoints()
    for _, column in pairs(bb.safePoints) do
        for _, point in pairs(column) do
            point.distance = nil
            point.next = nil
            point.maxHeight = nil
        end
    end
end

-- Reconstruct path from start to target cell
local function BuildPath(cell, originalPosition)
    local reversePath = {}

    -- build reversed path (unit -> start)
    while cell do
        local point = bb.safePoints[cell.x][cell.z]

        insert(reversePath, point.position)

        cell = point.next
    end

    -- build forward path (start -> unit)
    local path = {}

    for i = #reversePath, 1, -1 do
        insert(path, reversePath[i])
    end

    -- actual unit position last
    insert(path, originalPosition)

    return path, reversePath
end

-- Push valid neighboring cells into BFS queue
local function PushNeighbors(queue, cell, current)
    for i = 1, #CARDINAL_NEIGHBORS do
        local offset = CARDINAL_NEIGHBORS[i]

        local nx = cell.x + offset[1]
        local nz = cell.z + offset[2]

        local neighbor = GetSafePoint(nx, nz)

        -- not visited yet
        if neighbor and neighbor.distance == nil then
            neighbor.distance = current.distance + 1
            neighbor.next = cell
            neighbor.maxHeight = max(
                current.maxHeight,
                neighbor.position.y
            )

            insert(queue, Vec3(nx, 0, nz))
        end
    end
end

-- Find and remove lowest-height node from queue
local function PopLowestHeight(queue)
    local bestIndex = 1
    local bestHeight = huge

    for i = 1, #queue do
        local cell = queue[i]
        local height = bb.safePoints[cell.x][cell.z].position.y

        if height < bestHeight then
            bestHeight = height
            bestIndex = i
        end
    end

    return remove(queue, bestIndex)
end

-- Initialize BFS state
local function Initialize(self, safeArea)
    self.queue = {}
    self.finished = false

    bb.pathsToUnits = {}
    bb.reversePathsToUnits = {}

    -- clear previous BFS data
    ResetSafePoints()

    -- starting cell
    local startCell = GetClosestSafePoint(safeArea.center)
    local startPoint = bb.safePoints[startCell.x][startCell.z]

    startPoint.distance = 0
    startPoint.next = nil
    startPoint.maxHeight = safeArea.center.y

    insert(self.queue, startCell)

    self.is_initialized = true
end

-- Process BFS queue incrementally
local function ProcessBFS(self, maxIterations)
    local queue = self.queue
    local iterations = 0

    while #queue > 0 and iterations < maxIterations do
        local cell = PopLowestHeight(queue)
        local current = bb.safePoints[cell.x][cell.z]

        -- explore cardinal neighbors
        PushNeighbors(queue, cell, current)

        iterations = iterations + 1
    end

    return #queue == 0
end

-- Build paths for all rescue units
local function BuildUnitPaths(unitsToRescue)
    for i = 1, #unitsToRescue do
        local unitID = unitsToRescue[i]

        local position = Vec3(GetUnitPosition(unitID))
        local cell = GetClosestSafePoint(position)

        local path, reversePath = BuildPath(cell, position)

        bb.pathsToUnits[unitID] = path or {}
        bb.reversePathsToUnits[unitID] = reversePath or {} -- needed for nota_michelle_intro debug sensor
    end
end

-- Main behaviour
function Run(self, units, parameter)
    local safeArea = parameter.safeArea
    local unitsToRescue = parameter.unitsToRescue

    -- Initialization
    if not self.is_initialized then
        Initialize(self, safeArea)
    end

    -- BFS processing
    local bfsFinished = ProcessBFS(self, 100)

    -- BFS still running
    if not bfsFinished then
        return RUNNING
    end

    -- BFS finished -> build all unit paths once
    if not self.finished then
        BuildUnitPaths(unitsToRescue)
        self.finished = true
    end

    return SUCCESS
end

-- Reset behaviour state
function Reset(self)
    self.is_initialized = false
    self.finished = false
    self.queue = {}
end