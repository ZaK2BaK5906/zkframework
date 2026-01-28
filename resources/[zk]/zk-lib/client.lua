ZK = ZK or {}
ZK.Callbacks = ZK.Callbacks or {}

local callbackHandlers = {}
local pendingRequests = {}

local function registerCallback(name, handler)
  callbackHandlers[name] = handler
end

local function triggerCallback(name, cb, ...)
  local requestId = ZK.Utils.uuid()
  pendingRequests[requestId] = cb
  TriggerServerEvent('zk:lib:triggerCallback', name, requestId, ...)
end

exports('RegisterCallback', registerCallback)
exports('TriggerCallback', triggerCallback)

RegisterNetEvent('zk:lib:triggerCallback', function(name, requestId, ...)
  local handler = callbackHandlers[name]
  if not handler then
    TriggerServerEvent('zk:lib:callbackResponse', requestId, nil)
    return
  end

  local result = handler(...)
  TriggerServerEvent('zk:lib:callbackResponse', requestId, result)
end)

RegisterNetEvent('zk:lib:callbackResponse', function(requestId, result)
  local cb = pendingRequests[requestId]
  if not cb then
    return
  end

  pendingRequests[requestId] = nil
  cb(result)
end)
