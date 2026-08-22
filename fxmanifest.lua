server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 'ii_abual3bed | stdev'
description 'Vending Machine Robbery '

license 'MIT'
shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'qb-core',
    'qb-target',
    'progressbar',
    'st-mastermind',
    'cd_dispatch'
}

