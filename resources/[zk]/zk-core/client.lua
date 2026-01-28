RegisterNetEvent('zk:playerReady', function(player)
  ShutdownLoadingScreenNui()
  ShutdownLoadingScreen()
  TriggerEvent('chat:addMessage', {
    args = { 'ZK', ('Bienvenue %s'):format(player.name or 'citoyen') }
  })
end)
