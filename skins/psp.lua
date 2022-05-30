return function(ll)

-- New UI from Sony PSP

local sel = 1
local psel

local cx, cy, cw, ch, cg
local css, rcss = 2, 0

local f, bf

ll.cfg.pcht = ll.cfg.pcht or 60 * 5

local pikchv, pikcha = 0, 0
local pikchao = math.floor(1 / ll.cfg.pcht * 2 * 255 + 0.5)

function resize()
  r = math.min(W, H) / 30

  cg = H / 64
  cw = W / 5
  ch = (H - cg) / 6
  cx = W / 10
  cy = -H / 2

  f = love.graphics.setNewFont(math.min(W, H) / 30)
  bf = love.graphics.newFont(math.min(W, H) / 20)
end

love.window.setMode(800, 600, {resizable = true})

local my, mb, mpb

local sdir = 0
local function update()
  local ty = H / 2 - (ch + cg) * sel
  cy   = cy  + (ty - cy) * 0.1
  css  = css + (2 - css) * 0.2
  rcss = 2 - css + 1

  local sdi

  my = love.mouse.getY()
  mpb = mb
  if love.mouse.isDown(1) then mb = 1
  else mb = 0
  end
  if mb == 0 and mpb == 1 then
    if my <= H / 2 - ch
    then sdi = 1
    elseif my >= H / 2 + ch + cg
    then sdi = 2
    else sdi = 3
    end
  elseif love.keyboard.isScancodeDown('up', 'w')
  then sdi = 1
  elseif love.keyboard.isScancodeDown('down', 's')
  then sdi = 2
  elseif love.keyboard.isScancodeDown('return', 'space')
  then sdi = 3
  else sdi = 0
  end

  if sdi ~= sdir then
    if sdi ~= 0
    then rcss = css
      css = 1
      if sdi == 3
      then css = 1.5
      end
      psel = sel
    end
    sdir = sdi
    if sdi == 1
    then sel = sel - 1
    elseif sdi == 2
    then sel = sel + 1
    elseif sdi == 3 and ll.games[sel]
    then ll.mount(ll.games[sel])
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

local function scrCard(gme, x, y, w, h, a)
  if not gme.dat.scr then return end
  love.graphics.setColor(255, 255, 255, a / COLDIV)
  local p, n = gme.dat.scr[gme.scrprv], gme.dat.scr[gme.scrcur]
  love.graphics.draw(p, x, y, 0, w / p:getWidth(), h / p:getHeight())
  love.graphics.setColor(255, 255, 255, math.min(a, pikcha) / COLDIV)
  love.graphics.draw(n, x, y, 0, w / n:getWidth(), h / n:getHeight())
  love.graphics.setColor(0, 0, 0, 150 / COLDIV)
  love.graphics.rectangle('fill', x, y, w, h)
end

local function draw()
  love.graphics.setColor(0 / COLDIV, 50 / COLDIV, 75 / COLDIV)
  love.graphics.rectangle('fill', 0, 0, W, H)
  if ll.games[sel] then
    local cur = ll.games[sel]
    scrCard(cur, 0, 0, W, H, (css - 1) * 255)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(bf)
    love.graphics.printf(cur.desc, cx + cw * 2, cx, W - (cx + cw * 2))
  else love.graphics.setColor(255, 255, 255, 255)
    sel = #ll.games
  end
  love.graphics.setFont(f)
  local oy = 0
  for k, v in pairs(ll.games) do
    local x, w, h, g = cx, cw, ch, cg
    if k == sel then
      x = cx / css
      w = cw * css
      h = ch * css
      g = cg * 3
      oy = oy + cg * css
    elseif k == psel then
      x = cx / rcss
      w = cw * rcss
      h = ch * rcss
      oy = oy + cg * rcss
    end

    love.graphics.stencil(function()
      love.graphics.rectangle('fill', x, cy + oy, w, h, r)
    end)
    love.graphics.setStencilTest('greater', 0)

    love.graphics.setColor(50 / COLDIV, 50 / COLDIV, 50 / COLDIV, 100 / COLDIV)
    love.graphics.rectangle('fill', x, cy + oy, w, h)
    love.graphics.setColor(255, 255, 255, 255)

    scrCard(v, x, cy + oy, w, h, 255)
    love.graphics.setColor(255, 255, 255, 255)

    local th = f:getHeight(v.name)
    love.graphics.print(v.name, x + cg, cy + oy + h - th - cg)

    love.graphics.setStencilTest()
    love.graphics.rectangle('line', x, cy + oy, w, h, r)
    oy = oy + h + g
  end
  if #ll.games == 0 then
    love.graphics.print('No games', cx, cy - ch)
    love.graphics.setFont(bf)
    love.graphics.print('Add some to the library', cx, cy)
  end
end

return {
  update = update,
  draw = draw,
}

end
