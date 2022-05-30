return function(ll)

-- Basic cmd-like style UI
-- FIXME: Console scrolling

local cw, ch, ctw, cth
local ct = 'Love Loader v2.0\n(c) Er2 2022\tZlib License\n\n'
local cce = false
local buf = ''

local mb, mpb, mt = 0, 0, 0

local function ccp()
  local argv = {}
  for v in buf:gmatch '%S+'
  do table.insert(argv, v)
  end
  local cmd = (argv[1] or ''):lower()
  if cmd == '' then return '' -- nothing
  elseif cmd == 'help' then return 'Available commands:'
    .. '\nhelp\t\tThis command'
    .. '\nls\t\tList of games'
    .. '\ndir\t\tSame as ls'
    .. '\ncat\t<path>\tInformation about game'
    .. '\ninfo\t<path>\tSame as cat'
    .. '\nrun\t<path>\tStart game'
    .. '\nmount\t<path>\tSame as run'
    .. '\nchroot\t<path>\tSame as run'
    .. '\nclear\t\tClear screen'
    .. '\neval\t<code>\tExecute code'
  elseif cmd == 'clear' then
    ct = ''
    return ''
  elseif cmd == 'eval' then
    local code = buf:match '^%S+%s+(.*)'
    local f, err = load(code, 'test.lua')
    if not f then return err
    else return tostring(f() or 'nil')
    end
  elseif cmd == 'ls'
  or cmd == 'dir' then
    local r = ''
    if #ll.games == 0 then
      return ('%s: No games found. Add some to the library.'):format(argv[1])
    end
    for i = 1, #ll.games do
      local v = ll.games[i]
      r = r .. ('%s\t(%s)\t - %s\n'):format(v.dir, v.name, v.desc)
    end
    return r .. ('\nTotal: %3d games\n'):format(#ll.games)
  elseif cmd == 'cat'
  or cmd == 'info' then
    if not argv[2]
    then return ('%s: Game directory missing'):format(argv[1])
    end
    local r = ''
    for _, v in pairs(ll.games) do
      if argv[2] == v.dir
      or argv[2] == v.base .. v.dir
      then r = r..
        ( '\nFriendly name:\t%s'
        ..'\nDescription:\t%s'
        ..'\nLocation:\t%s%s'
        ..'\nMain file:\t%s'
        ..'\n\n\t\tScreenshots are not supported yet.'
        ..'\n'):format(v.name, v.desc, v.base, v.dir, v.main)
      end
    end
    if r == '' then r = 'Not found' end
    return r
  elseif cmd == 'run'
  or cmd == 'mount'
  or cmd == 'chroot' then
    local gme
    for _, v in pairs(ll.games) do
      if argv[2] == v.dir
      or argv[2] == v.base .. v.dir
      then if gme then
        return 'Error: multiple paths found, use full location'
        end
      gme = v end
    end
    if gme
    then ll.mount(gme)
         love.keyboard.setTextInput(false)
         return ''
    else return 'Not found'
    end
  else return 'Unknown command "'.. cmd .. '"'
  end
end

local function update()
  mpb = mb
  if love.mouse.isDown(1) then mb = 1
    if mpb ~= 1
    then mt = os.time()
    end
  else mb = 0
  end

  if mb == 0 and mpb == 1
  and os.time() - mt <= 1 then
    if love.system.getOS() == 'Android' then
      love.keyboard.setTextInput(
        not love.keyboard.hasTextInput(),
        0, H, W, ch)
    end
  end

  if not cce then
    cce = true
    local r = ccp()
    if #r ~= 0 then ct = ct.. '\n'.. r end
    ct = ct.. '\n> '
    buf = ''
  end
end

local utf8 = require 'utf8'
local function draw()
  love.graphics.setColor(255, 255, 255)

  local x, y = 0, 0
  for p, cde in utf8.codes(ct) do
    local chr = utf8.char(cde)
    if chr == '\n'
    then x, y = 0, y + 1
    elseif chr == '\r'
    then x = 0
    elseif chr == '\t'
    then x = x + 8 - (x % 8)
    elseif chr == '\v'
    then y = y + 1
    else love.graphics.print(chr, x * cw, y * ch)
      if x >= ctw
      then x, y = x - ctw, y + 1
      else x = x + 1
      end
    end
  end
  if os.time() % 2 == 0
  then love.graphics.rectangle('fill', x * cw, y * ch, cw, ch)
  end
end

function resize()
  local f = love.graphics.newFont(math.min(W, H) / 32)
  love.graphics.setFont(f)
  cw, ch = f:getWidth 'm', f:getHeight 'A'
  ctw, cth =
    math.floor(W / cw) - 1,
    math.floor(H / ch) - 1

  love.keyboard.setTextInput(true, 0, H, W, ch)
end

function love.textinput(txt)
  ct = ct.. txt
  buf = buf.. txt
end

function love.keypressed(k)
  if k == 'backspace' then
    local off = utf8.offset(buf, -1)
    if off then
      buf = buf:sub(1, off - 1)
      off = utf8.offset(ct, -1)
      if off
      then ct = ct:sub(1, off - 1)
      end
    end
  elseif k == 'return'
  then cce = false
  end
end

love.keyboard.setKeyRepeat(true)
love.window.setMode(800, 600, {resizable = true})

return {
  update = update,
  draw = draw,
  lovecb = {
    'textinput',
    'keypressed',
  },
}

end
