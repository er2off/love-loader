return function(ll)

local mx, my, mb, mpb
local dir, sc1, sc2, sclm

-- d   - direction (h, v, x, y, *)
-- c1  - coordinate before card (mouse) (be left or top)
-- c2  - coordinate after  card (mouse) (be right or bottom)
-- clm - other coordinate limit (mouse) (set -1 to disable)
function ll.kbInit(d, c1, c2, clim)
  if d == 'h' or d == 'v' or d == '*'
  then dir = d
  elseif d == 'y'
  then dir = 'v'
  elseif d == 'x'
  then dir = 'h'
  else error 'Direction must be *, h (x) or v (y)'
  end

  c1, c2 =
    tonumber(c1) or 0,
    tonumber(c2) or 0
  sc1, sc2, sclm =
    math.min(c1, c2),
    math.max(c1, c2),
    tonumber(clim) or -1
end

-- returns: <, >, o, m, nil
-- ^ and v if dir is *
function ll.kbGet()
  assert(dir, 'Call ll.kbInit(dir, coord1, coord2, coordlimit) before')
  mx, my = love.mouse.getPosition()
  mpb = mb
  if love.mouse.isDown(1) then mb = 1
  else mb = 0
  end

  if love.keyboard.isScancodeDown('up', 'w')
  then return dir == '*' and '^' or '<'

  elseif love.keyboard.isScancodeDown('left', 'a')
  then return '<'

  elseif love.keyboard.isScancodeDown('down', 's')
  then return dir == '*' and 'v' or '>'

  elseif love.keyboard.isScancodeDown('right', 'd')
  then return '>'

  elseif love.keyboard.isScancodeDown('return', 'space')
  then return 'o'

  elseif love.keyboard.isDown 'menu'
  then return 'm'

  elseif mb == 0 and mpb == 1 then -- unpressed
    if dir == 'h' then
    if sclm < 0 or my <= sclm then
      if mx <= sc1
      then return '<'
      elseif mx >= sc2
      then return '>'
      else return 'o'
      end
    end
    else
    if sclm < 0 or mx <= sclm then
      if my <= sc1
      then return '<'
      elseif my >= sc2
      then return '>'
      else return 'o'
      end
    end
    end

  end
end

end
