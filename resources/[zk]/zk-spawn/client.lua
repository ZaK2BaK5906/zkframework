local spawnPoint = vector4(215.76, -810.12, 30.73, 159.0)

local function spawnPlayer()
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do
    Wait(50)
  end

  local ped = PlayerPedId()
  FreezeEntityPosition(ped, true)
  SetEntityCoordsNoOffset(ped, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false)
  SetEntityHeading(ped, spawnPoint.w)
  Wait(500)
  FreezeEntityPosition(ped, false)
  DoScreenFadeIn(800)
end

RegisterNetEvent('zk:characterLoaded', function()
  spawnPlayer()
end)
