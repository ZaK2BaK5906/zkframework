local DB = exports['zk-db']
local Players = {}

local function getIdentifier(source, prefix)
  for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
    if identifier:find(prefix, 1, true) then
      return identifier
    end
  end
  return nil
end

local function getLicense(source)
  return getIdentifier(source, 'license:')
end

local function getDiscord(source)
  local discord = getIdentifier(source, 'discord:')
  if not discord then
    return nil
  end
  return discord:gsub('discord:', '')
end

local function loadOrCreateUser(license, discordId)
  local rows = DB:Query('SELECT id, license, discord_id FROM zk_users WHERE license = ? LIMIT 1', { license })
  if rows and rows[1] then
    if discordId and rows[1].discord_id ~= discordId then
      DB:Execute('UPDATE zk_users SET discord_id = ? WHERE id = ?', { discordId, rows[1].id })
    end
    return rows[1].id
  end

  DB:Execute('INSERT INTO zk_users (license, discord_id) VALUES (?, ?)', { license, discordId })
  local userId = DB:Scalar('SELECT id FROM zk_users WHERE license = ? LIMIT 1', { license })
  return userId
end

local function loadLastCharacter(userId)
  local rows = DB:Query('SELECT id, first_name, last_name, dob FROM zk_characters WHERE user_id = ? ORDER BY id DESC LIMIT 1', { userId })
  if rows and rows[1] then
    return rows[1]
  end
  return nil
end

local function buildPlayer(source, license, discordId, userId, character)
  return {
    source = source,
    license = license,
    discord_id = discordId,
    user_id = userId,
    character_id = character and character.id or nil,
    name = character and (character.first_name .. ' ' .. character.last_name) or GetPlayerName(source),
    metadata = {},
  }
end

local function setPlayer(source, player)
  Players[source] = player
  TriggerClientEvent('zk:playerReady', source, player)
  TriggerEvent('zk:playerReady', source, player)
end

local function onCharacterLoaded(source, character)
  local player = Players[source]
  if not player then
    return
  end

  player.character_id = character.id
  player.name = character.first_name .. ' ' .. character.last_name
  Players[source] = player

  TriggerClientEvent('zk:characterLoaded', source, player, character)
  TriggerEvent('zk:characterLoaded', source, player, character)

  local inv = exports['ox_inventory']
  if inv and inv.LoadInventory then
    inv:LoadInventory(source, character.id)
  end
end

local function setCharacter(source, character)
  onCharacterLoaded(source, character)
end

exports('SetCharacter', setCharacter)

RegisterNetEvent('zk:core:setCharacter', function(character)
  setCharacter(source, character)
end)

AddEventHandler('playerConnecting', function(_, setKickReason, deferrals)
  local src = source
  deferrals.defer()
  deferrals.update('ZK Framework: Initialisation...')

  CreateThread(function()
    local license = getLicense(src)
    if not license then
      deferrals.done('Licence FiveM introuvable.')
      return
    end

    local discordId = getDiscord(src)
    local userId = loadOrCreateUser(license, discordId)
    local character = loadLastCharacter(userId)
    local player = buildPlayer(src, license, discordId, userId, character)

    setPlayer(src, player)
    deferrals.done()

    if character then
      onCharacterLoaded(src, character)
    end
  end)
end)

AddEventHandler('playerDropped', function()
  local src = source
  local player = Players[src]
  if player then
    TriggerEvent('zk:playerDropped', src, player)
  end
  Players[src] = nil
end)

exports('GetPlayer', function(source)
  return Players[source]
end)

exports('GetLicense', function(source)
  local player = Players[source]
  return player and player.license or getLicense(source)
end)

exports('GetDiscord', function(source)
  local player = Players[source]
  return player and player.discord_id or getDiscord(source)
end)

exports('GetCharId', function(source)
  local player = Players[source]
  return player and player.character_id or nil
end)
