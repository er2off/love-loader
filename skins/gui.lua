return function(ll)

ll.cfg.pcht = ll.cfg.pcht or 60 * 5

local pikchv, pikcha = 0, 0
local pikchao = math.floor(1 / ll.cfg.pcht * 2 * 255 + 0.5)

local cx, cy, cw, ch
local f, bf

local sel = 1
local cdir

function resize()
  cw = W / 1.25
  ch = H / 1.25
  cx = (W - cw) / 2
  cy = (H - ch) / 2

  local th = math.min(W, H) / 8

  f  = love.graphics.newFont(th / 3)
  bf = love.graphics.newFont(th / 2)

  ll.kbInit('h', cx, cx + cw)
end

local function update()
  local sdi = ll.kbGet()

  if cdir ~= sdi then
    cdir = sdi
    if sdi == '<'
    then sel = sel - 1
    elseif sdi == '>'
    then sel = sel + 1
    elseif sdi == 'o' and ll.games[sel]
    then ll.mount(ll.games[sel])

    elseif sdi == 'm'
    and love.mouse.getX() >= W - 8
    then ll.devtools()
    end

    if sel < 1 then sel = #ll.games end
    if sel > #ll.games then sel = 1 end
  end

  pikchv = pikchv + 1
  if pikchv >= ll.cfg.pcht then
    pikchv = 0
    pikcha = 0
    for _, v in pairs(ll.games) do
      if v.dat.scr then
        v.scrprv = v.scrcur
        v.scrcur = v.scrcur + 1
        if v.scrcur > #v.dat.scr
        then v.scrcur = 1
        end
      end
    end
  else pikcha = math.min(255, pikcha + pikchao)
  end
end

local tm = 0
local function draw()
  love.graphics.setColor(0 / COLDIV, 50 / COLDIV, 75 / COLDIV)
  love.graphics.rectangle('fill', 0, 0, W, H)
  love.graphics.setColor(255, 255, 255, 100 / COLDIV)
  love.graphics.setLineWidth(8)
  love.graphics.setFont(bf)
  local t = 'Love Loader'
  local tw, th = bf:getWidth(t), bf:getHeight(t)
  love.graphics.print(t, W - tw - 8, H - th)

  tm = (tm + 0.02) % 6.28
  local c, pc, ps = tm, math.cos(tm), math.sin(tm)
  local oy = H / 2
  for x = 0, W + 8, 8 do
    c = c + 0.1
    local c, s = math.cos(c), math.sin(c)
    local cy, ncy, sy, nsy =
      pc * H / 12,
       c * H / 12,
      ps * H / 12,
       s * H / 12

    love.graphics.line(x - 8, sy     + oy, x-1, nsy     + oy)
    love.graphics.line(x - 8, sy/2   + oy, x-1, nsy/2   + oy)
    love.graphics.line(x - 8, cy/1.5 + oy, x-1, ncy/1.5 + oy)
    love.graphics.line(x - 8, cy*1.5 + oy, x-1, ncy*1.5 + oy)
    pc, ps = c, s
  end
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setLineWidth(1)

  local oy, t = 0, ''
  local gme = ll.games[sel]
  if gme then
    love.graphics.polygon('fill',
      8, H / 2,
      32, H / 2 - 32,
      32, H / 2 + 32)

    love.graphics.polygon('fill',
      W - 8, H / 2,
      W - 32, H / 2 - 32,
      W - 32, H / 2 + 32)

    love.graphics.stencil(function()
      love.graphics.rectangle('fill', cx, cy, cw, ch, 16)
    end)
    love.graphics.setStencilTest('greater', 0)
    love.graphics.setColor(50 / COLDIV, 50 / COLDIV, 50 / COLDIV, 100 / COLDIV)
    love.graphics.rectangle('fill', cx, cy, cw, ch)
    love.graphics.setColor(255, 255, 255, 255)

    if gme.dat.scr then
      local p, n = gme.dat.scr[gme.scrprv], gme.dat.scr[gme.scrcur]
      love.graphics.draw(p, cx, cy, 0, cw / p:getWidth(), ch / p:getHeight())
      love.graphics.setColor(255, 255, 255, pikcha / COLDIV)
      love.graphics.draw(n, cx, cy, 0, cw / n:getWidth(), ch / n:getHeight())
      love.graphics.setColor(0, 0, 0, 150 / COLDIV)
      love.graphics.rectangle('fill', cx, cy, cw, ch)
      love.graphics.setColor(255, 255, 255, 255)
    end

    oy = cy + ch / 1.25
    love.graphics.setFont(bf)
    love.graphics.print(gme.name, cx + 16, oy)
    oy = oy + bf:getHeight(gme.name)
    love.graphics.setFont(f)
    love.graphics.print(gme.desc, cx + 16, oy)
    love.graphics.setStencilTest()
    love.graphics.rectangle('line', cx, cy, cw, ch, 16)

  elseif ll.games[1] then
    sel = 1
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('Sorry :)', W / 2, H / 2)
  else love.graphics.setColor(255, 255, 255, 255)
    oy = H / 2.5
    t = 'No games'
    love.graphics.setFont(bf)
    love.graphics.print(t, (W - bf:getWidth(t)) / 2, oy)
    oy = oy + bf:getHeight(t)
    love.graphics.setFont(f)
    t = 'There are no projects/games to run'
    love.graphics.print(t, (W - f:getWidth(t)) / 2, oy)
  end
end

function error(msg)
  msg = tostring(msg)

  love.graphics.reset()
  love.graphics.origin()
  local bf = love.graphics.newFont(64)
  local f  = love.graphics.setNewFont(16)
  local perc = 0

  local q
  repeat
    perc = math.min(100, perc + 0.1 * math.random(50))

    love.graphics.clear(17/COLDIV, 113/COLDIV, 172/COLDIV)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(bf)
    love.graphics.print(':(', 64, 16)
    love.graphics.setFont(f)
    love.graphics.print(('%d%% complete'):format(perc), 64, 100)
    love.graphics.printf(msg, 64, 132, W - 64)
    love.graphics.print('(c) Love Loader and Er2', 8, H - 16 - 8)
    love.graphics.present()

    love.event.pump()
    for n, a,b,c in love.event.poll() do
      if n == 'quit'
      or n == 'mousereleased'
      or (n == 'keypressed' and a == 'escape')
      then q = true end
    end

    love.timer.sleep(0.5)
  until q or perc == 100

  -- Unfortunately, we can't restart Love in error handler
  llHome() -- but can outside of love.errorhandler
  return function() return 1 end
end

return {
  update = update,
  draw = draw,
}

end
