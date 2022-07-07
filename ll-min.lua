-- Minimal Love Loader API
-- Version 2.1
-- (c) Er2 2022 <er2@dismail.de>
-- Zlib License

if not llUsed then

COLDIV = love.getVersion() == 0 and 1 or 255
MOBILE = love.system.getOS() == 'Android'
  or love.system.getOS() == 'iOS'

if MOBILE
then love.window.setFullscreen(true)
end

function love.resize(x, y)
  W, H = x, y

  if resize then resize(W, H) end

  collectgarbage 'collect' -- because new font isn't clears
end
love.resize(love.graphics.getDimensions())

function llHome()
  love.event.push('quit')
end
function love.event.quit()
  llHome()
end

end
