
local root = 'games/'

-- games library and selection
local gms = {}
local sel = 1
local sgme

-- some internals
local cx, cy, cw, ch
local f, bf

function love.resize(x, y)
  W, H = x, y

  if resize then resize(W, H) end

  collectgarbage 'collect' -- because new font isn't clears
end

function resize()
  cw, ch = W / 1.25, H / 1.25
  cx, cy = (W - cw) / 2, (H - ch) / 2

  local th = math.min(W, H) / 8

  f  = love.graphics.newFont(th / 3)
  bf = love.graphics.newFont(th / 2)
end

love.resize(love.graphics.getDimensions())

local function gmeNew(cont, dir, file)
  local gme = {
    name = 'No name',
    desc = 'No description provided.',
    dir = dir,
    main = 'main.lua',
  }
  local fi = false
  cont = cont or ''
  cont = cont:gsub('[^\\]#[^\n]*', '')
  for v in cont:gmatch '([^\n]+)' do
    local k, v = v:match '^%s*([%w_]+)%s*=%s*(.*)%s*$'
    if k == 'name'
    or k == 'desc'
    or k == 'main'
    then gme[k] = v
      fi = true
    elseif k
    then error('unknown field "'.. k ..'" in "'.. file ..'"')
    end
  end
  if not fi then
    gme.name = dir
  end
  table.insert(gms, gme)
end

for _, v in pairs(love.filesystem.getDirectoryItems(root)) do
  local file = v..'/'.. 'info.ll'
  gmeNew(love.filesystem.read(root .. file), v, file)
end

local pf, mx, mb, mpb
local function update()
  mx = love.mouse.getX()
  mpb = mb
  mb = 0
  if love.mouse.isDown(1) then mb = 1
  end

  if mpb == 1 and mb == 0 then
    if mx <= cx then
      sel = sel - 1
      if sel < 1 then sel = #gms end
    elseif mx >= cx + cw then
      sel = sel + 1
      if sel > #gms then sel = 1 end
    else sgme = gms[sel]
    end
  end
end

local function draw()
  love.graphics.polygon('fill',
    8, H / 2,
    32, H / 2 - 32,
    32, H / 2 + 32)

  love.graphics.polygon('fill',
    W - 8, H / 2,
    W - 32, H / 2 - 32,
    W - 32, H / 2 + 32)

  local oy, t = 0, ''
  local gme = gms[sel]
  if gme then
    local ph = ch / 1.5
    love.graphics.rectangle('line', cx, cy, cw, ch)
    love.graphics.rectangle('fill', cx, cy, cw, ph)

    oy = cy + ph
    love.graphics.setFont(bf)
    love.graphics.print(gme.name, cx, oy)
    oy = oy + bf:getHeight(gme.name)
    love.graphics.setFont(f)
    love.graphics.print(gme.desc, cx, oy)

  else oy = H / 2
    t = 'No games'
    love.graphics.setFont(bf)
    love.graphics.print(t, (W - bf:getWidth(t)) / 2, oy)
    oy = oy + bf:getHeight(t)
    love.graphics.setFont(f)
    t = 'There is no projects/games to run'
    love.graphics.print(t, (W - f:getWidth(t)) / 2, oy)
  end
end

function love.handlers.quit(c)
  -- for some cases when event handler (like this one below) can't correctly close
  os.exit(c or 0)
end

while not sgme do
  -- event handling
  love.event.pump()
  for n, a,b,c,d,e,f in love.event.poll() do
    love.handlers[n](a,b,c,d,e,f)
  end

  -- update and drawing
  update()
  love.graphics.origin()
  love.graphics.clear(0, 0, 0)
  draw()
  love.graphics.present()
  love.timer.sleep(0.001)
end

love.graphics.setNewFont()
resize = nil
require(root .. sgme.dir ..'/'.. sgme.main:sub(1, -5))

-- things left:
-- W and H global variables
-- love.resize and optional global resize function
-- love.handlers.quit - modified but can be required
