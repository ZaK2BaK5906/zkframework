exports['zk-lib']:RegisterCallback('zk-demo:ping', function(source)
  return ('Callback OK depuis le serveur (%s)'):format(source)
end)

RegisterNetEvent('zk-demo:server:buySoda', function()
  TriggerClientEvent('chat:addMessage', source, {
    args = { 'ZK', 'Achat simulé: soda ajouté via ox_inventory.' }
  })

  local inv = exports['ox_inventory']
  if inv then
    inv:AddItem(source, 'water', 1)
  end
end)
