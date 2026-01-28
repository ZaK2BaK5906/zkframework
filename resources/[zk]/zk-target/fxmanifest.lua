fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'

dependencies {
  'zk-lib'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js'
}

shared_scripts {
  '@zk-lib/lib/shared.lua'
}

client_scripts {
  'client.lua'
}
