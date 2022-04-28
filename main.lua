
local root = 'games/'

-- games library and selection
local gms = {}
local sel = 1
local sgme

-- some internals
local cx, cy, cw, ch
local f, bf

local ffi = require 'ffi'
local fd
ffi.cdef [[
  int PHYSFS_mount(const char *, const char *, int);
  int PHYSFS_unmount(const char *);
]]

local function llResz()
  cw, ch = W / 1.25, H / 1.25
  cx, cy = (W - cw) / 2, (H - ch) / 2

  local th = math.min(W, H) / 8

  f  = love.graphics.newFont(th / 3)
  bf = love.graphics.newFont(th / 2)
end
resize = llResz

require 'll-min'
llUsed = true

local function chroot(dir, main)
  fd = love.filesystem.getSource() .. dir
  love.filesystem.setRequirePath(
    '?.lua;?/init.lua;'
    .. dir .. '/?.lua;'
    .. dir .. '/?/init.lua;'
  )
  -- FIXME: Bug in Linux (Debian)
  ffi.C.PHYSFS_mount(fd, '/', 0);
  if main then
    load(love.filesystem.read(dir ..'/'.. main), main)()
  end
end

local function escChroot()
  if fd then
    ffi.C.PHYSFS_unmount(fd);
    fd = nil
  end
end

local function gmeNew(cont, dir, file)
  local gme = {
    name = 'No name',
    desc = 'No description provided.',
    dir = dir,
    main = 'main.lua',
    pics = nil,
    psel = 2,
    ppsl = 1,
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
    elseif k == 'pic' then
      gme.pics = gme.pics or {}
      table.insert(gme.pics, v)
      fi = true
    elseif k == 'pics' then
      local t = {}
      v = v:sub(2, -2)
      for v in v:gmatch '%s*([^;]+%a+)%s*;?'
      do table.insert(t, v) end
      gme[k] = t
      fi = true
    elseif k
    then error('unknown field "'.. k ..'" in "'.. file ..'"')
    end
  end
  if gme.pics then
    for k, v in pairs(gme.pics) do
      gme.pics[k] = love.graphics.newImage(root .. dir ..'/'.. v)
    end
    gme.psel = math.min(2, #gme.pics)
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

local pcht = 60 * 5
local pchat = math.floor(1 / pcht * 2 * 255 + 0.5)
local pchv, pcha = 0, 0
local function llUpdate()
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

  pchv = pchv + 1
  if pchv >= pcht then
    pchv, pcha = 0, 0
    for _, v in pairs(gms) do
      if v.pics then
        v.ppsl = v.psel
        v.psel = v.psel + 1
        if v.psel > #v.pics
        then v.psel = 1 end
      end
    end
  else pcha = math.min(255, pcha + pchat)
  end
end

local function llDraw()
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
    if gme.pics then
      local p, n = gme.pics[gme.ppsl], gme.pics[gme.psel]
      love.graphics.draw(p, cx, cy, 0, cw / p:getWidth(), ph / p:getHeight())
      love.graphics.setColor(255, 255, 255, pcha / COLDIV)
      love.graphics.draw(n, cx, cy, 0, cw / n:getWidth(), ph / n:getHeight())
      love.graphics.setColor(255, 255, 255, 255)
    end
    love.graphics.rectangle('line', cx, cy, cw, ph)
    love.graphics.rectangle('line', cx, cy, cw, ch)

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

function llHome()
  escChroot()
  love.event.push('quit', 'restart')
end

local brk = false
while not brk and not sgme do
  -- event handling
  love.event.pump()
  for n, a,b,c,d,e,f in love.event.poll() do
    if n == 'quit' then
      escChroot()
      love.event.push('quit')
      brk = true; break
    end
    love.handlers[n](a,b,c,d,e,f)
  end

  -- update and drawing
  llUpdate()
  love.graphics.origin()
  love.graphics.clear(0, 0, 0)
  llDraw()
  love.graphics.present()
  love.timer.sleep(0.001)
end

if sgme then
  love.graphics.setNewFont()
  resize = nil
  chroot(root .. sgme.dir, sgme.main)
end
