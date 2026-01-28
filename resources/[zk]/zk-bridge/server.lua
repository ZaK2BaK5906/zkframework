local Core = exports['zk-core']
local Lib = exports['zk-lib']

QBCore = QBCore or {}
QBCore.Functions = QBCore.Functions or {}

ESX = ESX or {}

local defaultJob = {
  name = 'unemployed',
  label = 'Sans emploi',
  grade = { name = '0', level = 0 },
}

local function buildCitizenId(player)
  if player.character_id then
    return ('zk:%s'):format(player.character_id)
  end
  return ('zk-user:%s'):format(player.user_id)
end

local function buildQbPlayer(player)
  return {
    PlayerData = {
      source = player.source,
      citizenid = buildCitizenId(player),
      license = player.license,
      name = player.name,
      job = defaultJob,
    },
  }
end

local function buildEsxPlayer(player)
  local xPlayer = {}
  xPlayer.source = player.source
  xPlayer.identifier = player.license

  function xPlayer.getIdentifier()
    return player.license
  end

  function xPlayer.getName()
    return player.name
  end

  function xPlayer.addInventoryItem(item, count, metadata)
    local inv = exports['ox_inventory']
    if inv then
      inv:AddItem(player.source, item, count or 1, metadata)
    end
  end

  function xPlayer.removeInventoryItem(item, count)
    local inv = exports['ox_inventory']
    if inv then
      inv:RemoveItem(player.source, item, count or 1)
    end
  end

  return xPlayer
end

function QBCore.Functions.GetPlayer(source)
  local player = Core:GetPlayer(source)
  if not player then
    return nil
  end
  return buildQbPlayer(player)
end

function QBCore.Functions.CreateCallback(name, cb)
  Lib:RegisterCallback(name, function(source, ...)
    return cb(source, ...)
  end)
end

function QBCore.Functions.TriggerCallback(name, source, cb, ...)
  Lib:TriggerCallback(source, name, cb, ...)
end

function ESX.GetPlayerFromId(source)
  local player = Core:GetPlayer(source)
  if not player then
    return nil
  end
  return buildEsxPlayer(player)
end

function ESX.RegisterServerCallback(name, cb)
  Lib:RegisterCallback(name, function(source, ...)
    return cb(source, ...)
  end)
end

AddEventHandler('zk:characterLoaded', function(source, player)
  local qbPlayer = buildQbPlayer(player)
  local xPlayer = buildEsxPlayer(player)

  TriggerEvent('QBCore:Server:PlayerLoaded', source)
  TriggerClientEvent('QBCore:Client:OnPlayerLoaded', source)

  TriggerEvent('esx:playerLoaded', source, xPlayer)
end)
