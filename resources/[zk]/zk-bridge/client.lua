QBCore = QBCore or {}
QBCore.Functions = QBCore.Functions or {}

ESX = ESX or {}

function QBCore.Functions.TriggerCallback(name, cb, ...)
  exports['zk-lib']:TriggerCallback(name, cb, ...)
end

function ESX.TriggerServerCallback(name, cb, ...)
  exports['zk-lib']:TriggerCallback(name, cb, ...)
end
