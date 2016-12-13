print("[RE-FIX v2 by hikka]\nCrashcather enabled!")

local VelocityHook 				= true		-- Check entities for unreasonable velocity	
local UnreasonableHook 				= true		-- Check entities for unreasonable positions

local FreezeTime				= 1			-- Time entity is frozen for

local freezespeed 				= 2000
local removespeed 				= 2500

local MAX_REASONABLE_COORD 			= 15000
local MAX_REASONABLE_ANGLE 			= 15000
local MIN_REASONABLE_COORD 			= -MAX_REASONABLE_COORD
local MIN_REASONABLE_ANGLE 			= -MAX_REASONABLE_ANGLE

local UnreasonableEnts =
{
	[ "prop_physics" ] = true,
	[ "prop_ragdoll" ] = true
}
local EntList = {}
local EntIDs = {}

hook.Add("OnEntityCreated", "create entity", function(ent)
	if (!(ent:IsValid() && UnreasonableEnts[ent:GetClass()])) then return end
	EntIDs[ent:EntIndex()] = table.insert(EntList, ent)
end)

hook.Add("EntityRemoved", "remove entity", function(ent)
	local index = table.remove(EntIDs, ent:EntIndex())
	if (!index) then return end -- create entity wasn't called
	EntList[index] = nil
end)

function EnableVelocity(ent, enable)
	if !IsValid(ent) then return end

		ent:SetVelocity(vector_origin)

		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local subphys = ent:GetPhysicsObjectNum(i)
			if IsValid(subphys) then
				subphys:EnableMotion(enable)
				if !enable then
					subphys:EnableMotion(false)
					subphys:SetVelocity(vector_origin)
					subphys:SetMass(subphys:GetMass() * 20)
					subphys:Sleep()
					subphys:RecheckCollisionFilter()
				else
					subphys:EnableMotion(true)
					subphys:SetMass(subphys:GetMass() / 20)
					subphys:Wake()
					subphys:RecheckCollisionFilter()
				end
			end
		end

	ent:SetVelocity(vector_origin)
	ent:CollisionRulesChanged()
end

function KillVelocity(ent)
	EnableVelocity(ent, false)
	timer.Simple(FreezeTime, function() EnableVelocity(ent, true) end)
end

function util.IsReasonable(struct)
	if (struct.x >= MAX_REASONABLE_COORD || struct.x <= MIN_REASONABLE_COORD || 
		struct.y >= MAX_REASONABLE_COORD || struct.y <= MIN_REASONABLE_COORD || 
		struct.z >= MAX_REASONABLE_COORD || struct.y <= MIN_REASONABLE_COORD) then
		return false
	end
	return true
end
function isnan(num)
	return num ~= num
end

if (VelocityHook || UnreasonableHook) then
	hook.Add("Think","AMB_CrashCatcher",function()
		local nick
		local rMessage = "[GS] Removed %s (ID: %i) for moving too fast"
		local nMessage = "[GS] Removed %s (ID: %i) for having a nan position"
		local fMessage = "[GS] Froze %s (ID: %i) for moving too fast"
		local tempMessage
		local removeMessage
		local veloMessage = " (%f)\n"
		local nickString = "nick"

		for i = 0, #EntList do
			local ent = EntList[i]
			if IsValid(ent) then
				if (UnreasonableHook) then
					local pos = ent:GetPos()
					if (isnan(pos:Length()) || !util.IsReasonable(pos)) then
						tempMessage = string.format(nMessage, nick, ent:EntIndex())
						print(tempMessage)
						KillVelocity(ent)
						ent:Remove()
						continue
					end
				end

				if (VelocityHook) then
					local velo = ent:GetVelocity( ):Length()
					if velo >= freezespeed then
						KillVelocity(ent)

						nick = ent:GetNWString(nickString, ent:GetClass())
						tempMessage = string.format(fMessage, nick, ent:EntIndex())
						print(tempMessage .. string.format(veloMessage, velo))
					elseif velo >= removespeed then
						KillVelocity(ent)
						ent:Remove()

						nick = ent:GetNWString(nickString, ent:GetClass())
						tempMessage = string.format(rMessage, nick, ent:EntIndex())
						print(tempMessage .. string.format(veloMessage, velo))
					end
				end
			else
				EntList[i] = nil
				EntIDs[i] = nil
			end
		end
	end)
end
function util.IsReasonable(struct)
		if (struct.x >= MAX_REASONABLE_COORD || struct.x <= MIN_REASONABLE_COORD || 
			struct.y >= MAX_REASONABLE_COORD || struct.y <= MIN_REASONABLE_COORD || 
			struct.z >= MAX_REASONABLE_COORD || struct.y <= MIN_REASONABLE_COORD) then
			return false
		end
	return true
end
function isnan(num)
	return num ~= num
end

if (VelocityHook || UnreasonableHook) then
	hook.Add("Think","AMB_CrashCatcher",function()
		local nick
		local rMessage = "[GS] Removed %s (ID: %i) for moving too fast"
		local nMessage = "[GS] Removed %s (ID: %i) for having a nan position"
		local fMessage = "[GS] Froze %s (ID: %i) for moving too fast"
		local tempMessage
		local removeMessage
		local veloMessage = " (%f)\n"
		local nickString = "nick"

		for _, Ent in pairs(CrashEnts) do
			for _, ent in pairs(ents.FindByClass(Ent)) do
				if IsValid(ent) then
					if (UnreasonableHook) then
						local pos = ent:GetPos()
						if (isnan(pos:Length()) || !util.IsReasonable(pos)) then
							tempMessage = string.format(nMessage, nick, ent:EntIndex())
							print(tempMessage)
							KillVelocity(ent)
							ent:Remove()
							continue
						end
					end

					if (VelocityHook) then
						local velo = ent:GetVelocity( ):Length()
						if velo >= freezespeed then
							KillVelocity(ent)

							nick = ent:GetNWString(nickString, ent:GetClass())
							tempMessage = string.format(fMessage, nick, ent:EntIndex())
							print(tempMessage .. string.format(veloMessage, velo))
						elseif velo >= removespeed then
							KillVelocity(ent)
							ent:Remove()

							nick = ent:GetNWString(nickString, ent:GetClass())
							tempMessage = string.format(rMessage, nick, ent:EntIndex())
							print(tempMessage .. string.format(veloMessage, velo))
						end
					end
				end
			end
		end
	end)
end
