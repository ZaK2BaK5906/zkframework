local isActive = false
local currentOptions = {}
local lastPayload = nil

local Targets = {
  models = {},
  entities = {},
  zones = {},
}

local function vecDistance(a, b)
  return #(a - b)
end

local function addOption(list, option)
  list[#list + 1] = option
end

local function normalizeOptions(options)
  local list = {}
  for _, option in ipairs(options) do
    local cloned = ZK.Utils.deepCopy(option)
    cloned.distance = cloned.distance or 2.0
    list[#list + 1] = cloned
  end
  return list
end

local function addModel(models, options)
  local normalized = normalizeOptions(options)
  if type(models) ~= 'table' then
    models = { models }
  end
  for _, model in ipairs(models) do
    Targets.models[model] = normalized
  end
end

local function addEntity(entity, options)
  Targets.entities[entity] = normalizeOptions(options)
end

local function addZoneSphere(id, center, radius, options)
  Targets.zones[id] = {
    type = 'sphere',
    center = center,
    radius = radius,
    options = normalizeOptions(options),
  }
end

local function addZoneBox(id, center, size, heading, options)
  Targets.zones[id] = {
    type = 'box',
    center = center,
    size = size,
    heading = heading or 0.0,
    options = normalizeOptions(options),
  }
end

local function removeTarget(id)
  Targets.zones[id] = nil
  Targets.entities[id] = nil
  Targets.models[id] = nil
end

exports('AddModel', addModel)
exports('AddEntity', addEntity)
exports('AddZoneSphere', addZoneSphere)
exports('AddZoneBox', addZoneBox)
exports('RemoveTarget', removeTarget)

local function isPointInBox(point, box)
  local offset = point - box.center
  local heading = math.rad(box.heading)
  local cosH = math.cos(heading)
  local sinH = math.sin(heading)
  local localX = offset.x * cosH + offset.y * sinH
  local localY = -offset.x * sinH + offset.y * cosH

  return math.abs(localX) <= box.size.x / 2
    and math.abs(localY) <= box.size.y / 2
    and math.abs(offset.z) <= box.size.z / 2
end

local function raycastFromCamera(distance)
  local camCoords = GetGameplayCamCoord()
  local camRot = GetGameplayCamRot(2)
  local radZ = math.rad(camRot.z)
  local radX = math.rad(camRot.x)
  local direction = vector3(
    -math.sin(radZ) * math.cos(radX),
    math.cos(radZ) * math.cos(radX),
    math.sin(radX)
  )
  local destination = camCoords + direction * distance
  local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0)
  local _, hit, endCoords, _, entityHit = GetShapeTestResult(ray)
  return hit, endCoords, entityHit
end

local function buildOptionsFromTarget(entity, coords)
  local options = {}
  local playerCoords = GetEntityCoords(PlayerPedId())

  if entity and entity ~= 0 then
    local model = GetEntityModel(entity)
    local modelOptions = Targets.models[model]
    if modelOptions then
      for _, option in ipairs(modelOptions) do
        if vecDistance(playerCoords, coords) <= option.distance then
          if not option.canInteract or option.canInteract({ entity = entity, coords = coords }) then
            addOption(options, option)
          end
        end
      end
    end

    local entityOptions = Targets.entities[entity]
    if entityOptions then
      for _, option in ipairs(entityOptions) do
        if vecDistance(playerCoords, coords) <= option.distance then
          if not option.canInteract or option.canInteract({ entity = entity, coords = coords }) then
            addOption(options, option)
          end
        end
      end
    end
  end

  for _, zone in pairs(Targets.zones) do
    local inZone = false
    if zone.type == 'sphere' then
      inZone = vecDistance(playerCoords, zone.center) <= zone.radius
    elseif zone.type == 'box' then
      inZone = isPointInBox(playerCoords, zone)
    end

    if inZone then
      for _, option in ipairs(zone.options) do
        if vecDistance(playerCoords, zone.center) <= option.distance then
          if not option.canInteract or option.canInteract({ coords = zone.center }) then
            addOption(options, option)
          end
        end
      end
    end
  end

  return options
end

local function sendOptions(options)
  local payload = {}
  for index, option in ipairs(options) do
    payload[index] = {
      id = index,
      label = option.label,
      icon = option.icon or '⚡',
      danger = option.danger or false,
    }
  end

  local serialized = json.encode(payload)
  if serialized ~= lastPayload then
    lastPayload = serialized
    SendNUIMessage({ action = 'options', options = payload })
  end
end

local function activateTarget()
  if isActive then
    return
  end

  isActive = true
  lastPayload = nil
  SendNUIMessage({ action = 'open' })

  CreateThread(function()
    while isActive do
      local hit, coords, entity = raycastFromCamera(6.0)
      if hit then
        currentOptions = buildOptionsFromTarget(entity, coords)
      else
        currentOptions = {}
      end
      sendOptions(currentOptions)
      Wait(80)
    end
  end)
end

local function deactivateTarget()
  isActive = false
  currentOptions = {}
  lastPayload = nil
  SendNUIMessage({ action = 'close' })
end

RegisterCommand('+zktarget', function()
  activateTarget()
end)

RegisterCommand('-zktarget', function()
  deactivateTarget()
end)

RegisterKeyMapping('+zktarget', 'ZK Target', 'keyboard', 'LMENU')

RegisterNUICallback('select', function(data, cb)
  local option = currentOptions[data.id]
  if not option then
    cb({ ok = false })
    return
  end

  if option.serverEvent then
    TriggerServerEvent(option.serverEvent, option.args)
  elseif option.event then
    TriggerEvent(option.event, option.args)
  end

  cb({ ok = true })
end)
