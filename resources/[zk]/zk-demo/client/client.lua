CreateThread(function()
  local atmModels = {
    GetHashKey('prop_atm_01'),
    GetHashKey('prop_atm_02'),
    GetHashKey('prop_atm_03'),
  }

  exports['zk-target']:AddModel(atmModels, {
    {
      label = 'Consulter solde',
      icon = '💳',
      event = 'zk-demo:client:atm',
    },
  })

  exports['zk-target']:AddModel(GetHashKey('prop_vend_soda_01'), {
    {
      label = 'Acheter soda',
      icon = '🥤',
      serverEvent = 'zk-demo:server:buySoda',
    },
  })

  exports['zk-target']:AddZoneSphere('zk-demo:legion', vector3(215.76, -810.12, 30.73), 3.5, {
    {
      label = 'Point de rassemblement',
      icon = '📍',
      event = 'zk-demo:client:ping',
    },
  })
end)

RegisterNetEvent('zk-demo:client:atm', function()
  TriggerEvent('chat:addMessage', { args = { 'ZK', 'ATM: solde fictif 2500$.' } })
end)

RegisterNetEvent('zk-demo:client:ping', function()
  exports['zk-lib']:TriggerCallback('zk-demo:ping', function(response)
    TriggerEvent('chat:addMessage', { args = { 'ZK', response } })
  end)
end)
