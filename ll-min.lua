-- minimal Love Loader API

if not llUsed then

COLDIV = love.getVersion() == 0 and 1 or 255

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
