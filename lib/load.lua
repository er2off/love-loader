return function(ll)

function ll.addGame(file, cont)
  local dir = ll.fsDir(file)
  file = ll.fsFile(file)
  local ext = file:match '%.(%w+)$'
  print(file, ext, dir)
  return 'NO!', nil
end

function ll.gameAdd(conf, file, base, dir)
  local gme = ll.gameNew(conf, file, base, dir)
  gme.dat = {}

  if gme.screens and gme.screens[1] then
    gme.dat.scr = {}
    for i = 1, #gme.screens do
      table.insert(gme.dat.scr, love.graphics.newImage(ll.cfg.root .. gme.dir ..'/'.. gme.screens[i]))
    end
  end

  table.insert(ll.games, gme)
  return gme
end

local lfs = love.filesystem
local info = lfs.getInfo

for _, dir in pairs(love.filesystem.getDirectoryItems(ll.cfg.root)) do
  local isDir
  if info
  then isDir = info(ll.cfg.root .. dir).type == 'directory'
  else isDir = lfs.isDirectory(ll.cfg.root .. dir)
  end

  if isDir then
    local file = ll.cfg.root .. dir..'/'.. 'info.ll'
    local realDir = love.filesystem.getRealDirectory(file)
      or love.filesystem.getRealDirectory(ll.cfg.root .. dir..'/main.lua')
    if realDir
    then ll.gameAdd(
      love.filesystem.read(file),
      file,
      realDir ..'/'.. ll.cfg.root,
      dir
    )
    end
  end
end

end
