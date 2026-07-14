local sensorInfo = {
	name = "Get Fark Move",
	desc = "Returns true/false if farks should move",
	author = "Dolezafi",
	date = "2026-06-30",
	license = "MIT",
}

VFS.Include("modules.lua")
VFS.Include(modules.attach.data.path .. modules.attach.data.head)

attach.Module(modules, "message")

local EVAL_PERIOD_DEFAULT = -1

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

local function distance(v1, v2)
	if v1 == nil or v2 == nil then
		return math.huge
	end

	local dx = v1.x - v2.x
	local dy = (v1.y or 0) - (v2.y or 0)
	local dz = v1.z - v2.z

	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function length(v)
	if v == nil then
		return 0
	end

	return math.sqrt(
		(v.x or 0) * (v.x or 0) +
		(v.y or 0) * (v.y or 0) +
		(v.z or 0) * (v.z or 0)
	)
end

return function()
	local tempFrontline = bb.tempFrontline
	local frontline = bb.frontline

	if tempFrontline ~= nil and frontline ~= nil then
		if distance(tempFrontline, frontline) > 200
			and length(tempFrontline) > length(frontline) then
			return true
		end
	end

	if bb.units ~= nil and bb.units.farks ~= nil and bb.units.farks[1] ~= nil then
		local queue = Spring.GetCommandQueue(bb.units.farks[1], 1)
		if queue ~= nil and #queue < 1 then
			return true
		end
	end

	return false
end