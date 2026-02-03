---@type ash.player
local ash_player = require( "ash.player" )


local cv_dev = GetConVar( "developer" )


local IsValid = IsValid

local car = "vapid_stanier_retro"

local maps_spawns_cars = {
	[ "gm_tritype_racecity_v1" ] = {
		{
			Vector( 12792, -1325, 100 ),
			Angle( 0, 90, 0 )
		},
	}
}

local map_name = game.GetMap()
local spawns = maps_spawns_cars[ map_name ]

---@param ply Player
local function spawnCar( ply )
	if not spawns then
		return
	end

	for i = 1, #spawns do
		local v = spawns[ i ]

		local car = ents.Create( car )

		if car then
			car:Spawn()

			return car
		end
	end
end

hook.Add( "ash.player.PostSpawn", "Default", function( ply )
	local ent = spawnCar( ply )

	if ent == nil then
		return
	end

	local old_car = ply:GetNW2Entity( "RacedVehicle" )

	if IsValid( old_car ) then
		old_car:Remove()
	end

	if IsValid( ent ) then
		ent:SetPos( ply:GetPos() )

		local ang = ply:GetAngles()
		ang[ 1 ] = 0
		ang[ 3 ] = 0

		ent:SetAngles( ang )
		ply:SetNW2Entity( "RacedVehicle", ent )
		ply:EnterVehicle( ent )
	end
end )

hook.Add( "CanPlayerEnterVehicle", "Default", function()
	return true
end )

hook.Add( "CanExitVehicle", "Default", function()
	if cv_dev:GetBool() then
		return true
	end

	return false
end )

local function createSpawns()
	if not spawns then
		return
	end

	timer.Simple( 1, function()
		ash_player.cleanSpawnPoints()

		for i = 1, #spawns do
			local v = spawns[ i ]

			local ent = ents.Create( "info_player_start" )
			ent:SetPos( v[ 1 ] )
			ent:SetAngles( v[ 2 ] )

			ent:Spawn()

			ash_player.addSpawnPoint( ent, v[ 1 ], v[ 2 ] )
		end
	end )
end

createSpawns()

hook.Add( "InitPostEntity", "Default", createSpawns )
hook.Add( "PostCleanupMap", "Default", createSpawns )


concommand.Add("race_debug_dir", function( ply )
	ply:PrintMessage(HUD_PRINTCONSOLE, tostring( ply:GetAimVector( ) ) )
end)