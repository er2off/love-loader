return {
  entry = 'main.lua',
  output = 'build/main.lua',
  plug = {
    require 'plug.minify' {
      extGlob = {
        'love',
        'llUsed',
        'llHome',
        'resize',
        'COLDIV',
        'W', 'H',
      }
    },
  }
}
