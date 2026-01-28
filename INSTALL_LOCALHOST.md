# ZK Framework (2026) - Installation locale

## Prérequis
- FXServer artifact récent (cerulean) installé.
- MySQL/MariaDB actif.
- [oxmysql](https://github.com/overextended/oxmysql) installé dans `resources/`.
- [ox_inventory](https://github.com/overextended/ox_inventory) installé dans `resources/`.

## Création de la base
1. Créez une base `zk_framework`.
2. Importez la migration :
   - `sql/001_users.sql`
   - `sql/002_characters.sql`
   - `sql/003_schema_migrations.sql`

## Installation des ressources
1. Copiez `resources/[zk]` dans le dossier `resources/` de votre FXServer (pas de ZIP binaire).
2. Assurez-vous que `zk-db` est avant `zk-core` et les modules ZK.

## Configuration `server.cfg`
- Utilisez l'exemple fourni : `server.cfg`.
- Mettez votre clé licence, votre chaîne MySQL, et vos endpoints.

## Ordre d'ensure
```
ensure oxmysql
ensure ox_inventory
ensure zk-loadingscreen
ensure zk-db
ensure zk-lib
ensure zk-core
ensure zk-identity
ensure zk-spawn
ensure zk-target
ensure zk-bridge
ensure zk-demo
```

## Lancer le serveur
1. Démarrez FXServer.
2. Connectez-vous via FiveM.
3. La création d'identité apparaît si aucun personnage.
4. Après validation : spawn Legion + ox_inventory prêt.

## Bridge ESX/QBCore
- `ESX` et `QBCore` sont auto-créés dans `zk-bridge`.
- Les callbacks ESX/QB passent par `zk-lib`.
- Inventaire via ox_inventory uniquement.

## Vérification rapide
- Zone Legion Square : test du target.
- ATM : message de test.
- Vending : achat test + item `water` via ox_inventory.
