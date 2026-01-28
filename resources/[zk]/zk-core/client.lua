RegisterNetEvent('zk:playerReady', function(player)
  TriggerEvent('chat:addMessage', {
    args = { 'ZK', ('Bienvenue %s'):format(player.name or 'citoyen') }
  })
end)
