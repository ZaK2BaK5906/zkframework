local RESOURCE = GetCurrentResourceName()

local function log(msg)
  print(('[ZK-DB] %s'):format(msg))
end

local function query(sql, params)
  return MySQL.query.await(sql, params or {})
end

local function execute(sql, params)
  return MySQL.update.await(sql, params or {})
end

local function scalar(sql, params)
  return MySQL.scalar.await(sql, params or {})
end

exports('Query', query)
exports('Execute', execute)
exports('Scalar', scalar)

local function ensureMigrationsTable()
  execute([[CREATE TABLE IF NOT EXISTS zk_schema_migrations (
    name VARCHAR(128) NOT NULL UNIQUE,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  )]], {})
end

local function migrationApplied(name)
  local rows = query('SELECT name FROM zk_schema_migrations WHERE name = ? LIMIT 1', { name })
  return rows and rows[1] ~= nil
end

local function applyMigration(name, sql)
  if migrationApplied(name) then
    return
  end

  execute(sql, {})
  execute('INSERT INTO zk_schema_migrations (name) VALUES (?)', { name })
  log(('Migration appliquée: %s'):format(name))
end

local function runMigrations()
  ensureMigrationsTable()

  local migrations = {
    { name = '001_users.sql', file = 'migrations/001_users.sql' },
    { name = '002_characters.sql', file = 'migrations/002_characters.sql' },
    { name = '003_schema_migrations.sql', file = 'migrations/003_schema_migrations.sql' },
  }

  for _, migration in ipairs(migrations) do
    local sql = LoadResourceFile(RESOURCE, migration.file)
    if sql and sql ~= '' then
      applyMigration(migration.name, sql)
    else
      log(('Migration introuvable: %s'):format(migration.file))
    end
  end
end

AddEventHandler('onResourceStart', function(name)
  if name ~= RESOURCE then
    return
  end

  runMigrations()
  log('ZK DB ready')
end)
