return function(ll)

function ll.gameAdd(conf, file, base, dir)
  local gme = ll.gameNew(conf, file, base, dir)
  table.insert(ll.games, gme)
  return gme
end

end
