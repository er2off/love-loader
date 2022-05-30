return function(ll)

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

for _, dir in pairs(love.filesystem.getDirectoryItems(ll.cfg.root)) do
  local file = ll.cfg.root .. dir..'/'.. 'info.ll'
  ll.gameAdd(
    love.filesystem.read(file),
    file,
    love.filesystem.getSource():match '(.*)[\\/]*' ..'/'.. ll.cfg.root, -- TODO: AppData folders support
    dir
  )
end

end
