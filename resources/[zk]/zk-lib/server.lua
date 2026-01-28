ZK = ZK or {}
ZK.Callbacks = ZK.Callbacks or {}

local callbackHandlers = {}
local pendingRequests = {}

local function registerCallback(name, handler)
  callbackHandlers[name] = handler
end

local function triggerCallback(source, name, cb, ...)
  local requestId = ZK.Utils.uuid()
  pendingRequests[requestId] = cb
  TriggerClientEvent('zk:lib:triggerCallback', source, name, requestId, ...)
end

exports('RegisterCallback', registerCallback)
exports('TriggerCallback', triggerCallback)

RegisterNetEvent('zk:lib:triggerCallback', function(name, requestId, ...)
  local src = source
  local handler = callbackHandlers[name]
  if not handler then
    TriggerClientEvent('zk:lib:callbackResponse', src, requestId, nil)
    return
  end

  local result = handler(src, ...)
  TriggerClientEvent('zk:lib:callbackResponse', src, requestId, result)
end)

RegisterNetEvent('zk:lib:callbackResponse', function(requestId, result)
  local cb = pendingRequests[requestId]
  if not cb then
    return
  end

  pendingRequests[requestId] = nil
  cb(result)
end)
