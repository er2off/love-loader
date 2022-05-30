return function(ll)

local ffi = require 'ffi'
ffi.cdef [[
  int PHYSFS_mount(const char *, const char *, int);
  int PHYSFS_unmount(const char *);
]]

function ll.mount(gme)
  local mdir = gme.base .. gme.dir

  love.filesystem.setRequirePath(''
    .. mdir .. '/?.lua;'
    .. mdir .. '/?/init.lua;'
    .. '?.lua;?/init.lua;'
  )
  -- FIXME: Bug may appear in Linux. Recompile Love2D or use official PPA.
  if ffi.C.PHYSFS_mount(mdir, '/', 0) == 0
  then error 'Cannot mount'
  else
    ll.mdir = mdir
    ll.mgme = gme
  end
end

function ll.umount()
  if ll.mdir ~= nil then
    ffi.C.PHYSFS_unmount(ll.mdir)
    ll.mdir = nil
  end
end

end
