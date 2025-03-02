fx_version 'cerulean'
game 'gta5'

name 'Firing Range'
author 'User'
description 'FiveM/ESX Firing Range Script'


dependency 'ox_inventory'


shared_scripts {
    '@es_extended/locale.lua',
    'config.lua'
}


client_scripts {
    'client/client.lua',
    'client/nui.lua'
}


server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'server/server.lua'
}


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/background.png'
}