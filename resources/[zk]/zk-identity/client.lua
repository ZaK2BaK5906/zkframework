local isOpen = false

local function openCreator()
  if isOpen then
    return
  end
  isOpen = true
  SetNuiFocus(true, true)
  SetCursorLocation(0.5, 0.5)
  SendNUIMessage({ action = 'open' })
  TriggerServerEvent('zk-identity:enterCreator')
end

local function closeCreator()
  if not isOpen then
    return
  end
  isOpen = false
  SetNuiFocus(false, false)
  SetCursorLocation(0.5, 0.5)
  SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('zk:playerReady', function()
  exports['zk-lib']:TriggerCallback('zk-identity:hasCharacter', function(hasCharacter)
    if not hasCharacter then
      openCreator()
    end
  end)
end)

RegisterNetEvent('zk:characterLoaded', function()
  closeCreator()
end)

RegisterNetEvent('zk-identity:notify', function(message)
  TriggerEvent('chat:addMessage', { args = { 'ZK', message } })
end)

RegisterNetEvent('zk-identity:close', function()
  closeCreator()
end)

RegisterNUICallback('createCharacter', function(data, cb)
  TriggerServerEvent('zk-identity:createCharacter', data)
  cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
  closeCreator()
  cb({ ok = true })
end)
