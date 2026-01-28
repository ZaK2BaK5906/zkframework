ZK = ZK or {}
ZK.Utils = ZK.Utils or {}
ZK.Logger = ZK.Logger or {}
ZK.RateLimiter = ZK.RateLimiter or {}

local function formatPrefix(level)
  return ('[ZK][%s]'):format(level)
end

function ZK.Logger.debug(msg)
  print(('%s %s'):format(formatPrefix('DEBUG'), msg))
end

function ZK.Logger.info(msg)
  print(('%s %s'):format(formatPrefix('INFO'), msg))
end

function ZK.Logger.warn(msg)
  print(('%s %s'):format(formatPrefix('WARN'), msg))
end

function ZK.Logger.error(msg)
  print(('%s %s'):format(formatPrefix('ERROR'), msg))
end

function ZK.Utils.deepCopy(value)
  if type(value) ~= 'table' then
    return value
  end

  local copy = {}
  for k, v in pairs(value) do
    copy[ZK.Utils.deepCopy(k)] = ZK.Utils.deepCopy(v)
  end
  return copy
end

function ZK.Utils.clamp(value, min, max)
  return math.min(math.max(value, min), max)
end

function ZK.Utils.uuid()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return template:gsub('[xy]', function(char)
    local rand = math.random(0, 15)
    local out = char == 'x' and rand or (rand % 4 + 8)
    return string.format('%x', out)
  end)
end

function ZK.Utils.tableSize(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

function ZK.Utils.merge(target, source)
  local output = ZK.Utils.deepCopy(target or {})
  for k, v in pairs(source or {}) do
    if type(v) == 'table' and type(output[k]) == 'table' then
      output[k] = ZK.Utils.merge(output[k], v)
    else
      output[k] = ZK.Utils.deepCopy(v)
    end
  end
  return output
end

local limiterState = {}

function ZK.RateLimiter.allow(key, intervalMs, maxHits)
  local now = GetGameTimer()
  limiterState[key] = limiterState[key] or {}
  local state = limiterState[key]

  state.window = state.window or now
  state.hits = state.hits or 0

  if now - state.window > intervalMs then
    state.window = now
    state.hits = 0
  end

  if state.hits >= maxHits then
    return false
  end

  state.hits = state.hits + 1
  return true
end
