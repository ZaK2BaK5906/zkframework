local DB = exports['zk-db']
local Core = exports['zk-core']

local function sanitize(text, limit)
  if type(text) ~= 'string' then
    return nil
  end
  text = text:gsub('[^%w%-\'%s]', ''):gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
  if #text < 2 or #text > limit then
    return nil
  end
  return text
end

exports['zk-lib']:RegisterCallback('zk-identity:hasCharacter', function(source)
  local player = Core:GetPlayer(source)
  return player and player.character_id ~= nil
end)

RegisterNetEvent('zk-identity:enterCreator', function()
  local src = source
  SetPlayerRoutingBucket(src, 1000 + src)
end)

RegisterNetEvent('zk-identity:createCharacter', function(payload)
  local src = source
  if not payload or type(payload) ~= 'table' then
    return
  end

  local firstName = sanitize(payload.first_name, 24)
  local lastName = sanitize(payload.last_name, 24)
  local dob = payload.dob

  if not firstName or not lastName then
    TriggerClientEvent('zk-identity:notify', src, 'Identité invalide.')
    return
  end

  local player = Core:GetPlayer(src)
  if not player then
    return
  end

  DB:Execute('INSERT INTO zk_characters (user_id, first_name, last_name, dob) VALUES (?, ?, ?, ?)', {
    player.user_id,
    firstName,
    lastName,
    dob ~= '' and dob or nil,
  })

  local charId = DB:Scalar('SELECT id FROM zk_characters WHERE user_id = ? ORDER BY id DESC LIMIT 1', { player.user_id })
  if not charId then
    TriggerClientEvent('zk-identity:notify', src, 'Erreur de création.')
    return
  end

  local character = {
    id = charId,
    first_name = firstName,
    last_name = lastName,
    dob = dob,
  }

  SetPlayerRoutingBucket(src, 0)
  TriggerClientEvent('zk-identity:close', src)
  Core:SetCharacter(src, character)
end)
