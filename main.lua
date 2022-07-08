local ll = require 'lib.main'
error = love.errhand or love.errorhandler

function splash()
  love.graphics.setColor(255, 255, 255, 100 / COLDIV)
  if ll.mgme.screens and ll.mgme.screens[1] then
    local img = love.graphics.newImage(ll.mgme.screens[1])
    love.graphics.draw(img, 0, 0, 0, W / img:getWidth(), H / img:getHeight())
  end
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print('Loading '..ll.mgme.name, W / 2, H / 2)
end

ll.skin = require 'skins.psp' (ll)

require 'll-min'
llUsed = true

if love.errorhandler
then love.errorhandler = error
else love.errhand = error
end

local brk = false
while not brk and not ll.mdir do
  -- event handling
  love.event.pump()
  for n, a,b,c in love.event.poll() do
    if n == 'quit'
    or (n == 'keypressed' and a == 'escape')
    then ll.umount()
      love.event.push('quit')
      brk = true; break
    end
    love.handlers[n](a,b,c)
  end

  -- update and drawing
  ll.skin.update()
  love.graphics.origin()
  love.graphics.clear(0, 0, 0)
  ll.skin.draw()
  love.graphics.present()
  love.timer.sleep(0.001)
end

if ll.mdir then
  love.graphics.setNewFont()
  resize = nil

  love.graphics.clear(0, 0, 0)
  splash()
  love.graphics.present()

  if ll.skin.lovecb then
    for _, v in pairs(ll.skin.lovecb)
    do love[v] = nil
    end
  end

  love.filesystem.setIdentity(ll.mgme.dir)
  local f, err = load(love.filesystem.read(ll.mgme.main), ll.mgme.name)
  if not f then error(err)
  else xpcall(f, function(e)
    error(e)
    llHome()
  end)
  end

  local t = {
    title = 'Untitled',
    window = {
      width = W, height = H,
      fullscreen = love.window.getFullscreen(),
      resizable = false,
    },
    audio = {
      mixwithsystem = true,
      mic = false,
    },
    modules = {},
    console = false,
    accelerometerjoystick = true,
    gammacorrect = false,
  }
  if pcall(require, 'conf')
  and love.conf
  then pcall(love.conf, t)
  end

  if t.console and love._openConsole
  then love._openConsole()
  end

  love._setGammaCorrect(t.gammacorrect)
  if MOBILE then
    love._setAccelerometerAsJoystick(t.accelerometerjoystick)
    if love.isVersionCompatible '11.3' then
      love._setAudioMixWithSystem(t.audio.mixwithsystem)
      love._requestRecordingPermission(t.audio.mic)
    end
    love.filesystem._setAndroidSaveExternal(t.externalstorage)
  end

  if t.window then
    love.window.setTitle(t.window.title or t.title)
    local ww, wh, wi =
      t.window.width, t.window.height,
      t.window.icon
    t.window.width, t.window.height, t.window.title, t.window.icon
      = nil
    assert(love.window.setMode(ww, wh, t.window), 'Error setting up window')
    if wi
    then love.window.setIcon(love.image.newImageData(wi))
    end
  end
  love.resize(love.graphics.getDimensions())
end

