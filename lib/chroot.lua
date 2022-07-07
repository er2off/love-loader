return function(ll)

ll.mdir = nil
ll.mgme = nil

local ffi = require 'ffi'
ffi.cdef [[
  int PHYSFS_mount(const char *, const char *, int);
  int PHYSFS_unmount(const char *);
]]

local baseReq = '?.lua;?/init.lua;'
function ll.mount(gme)
  local mdir = gme.base .. gme.dir
  ll.mgme = gme

  love.filesystem.setRequirePath(''
    .. mdir .. '/?.lua;'
    .. mdir .. '/?/init.lua;'
    .. baseReq
  )
  -- FIXME: Bug may appear in Linux. Recompile Love2D or use official PPA.
  if ffi.C.PHYSFS_mount(mdir, '/', 0) == 0
  then error('Cannot mount '..mdir)
    love.filesystem.setRequirePath(baseReq)
  else ll.mdir = mdir
  end
end

function ll.umount()
  if ll.mdir ~= nil then
    ffi.C.PHYSFS_unmount(ll.mdir)
    ll.mdir = nil
  end
end

end
