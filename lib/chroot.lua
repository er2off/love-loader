return function(ll)

ll.mdir = nil
ll.mgme = nil

function ll.mount(gme)
  --[[
    ll.mdir = gme.base .. gme.dir
    ll.mgme = gme
    --[=[
    if gme.main then
      print('Load', ll.mdir ..'/'.. gme.main)
    end
    --]=]
  --]]
  error 'unimplemented'
end

function ll.umount()
  if ll.mdir ~= nil then
    ll.mdir = nil
    error 'unimplemented'
  end
end

end
