local ll = {}

ll.cfg = {
  root = 'games/',
}

require 'lib.fs'     (ll)
require 'lib.game'   (ll)
require 'lib.chroot' (ll)
require 'lib.load'   (ll)
require 'lib.keyb'   (ll)

function ll.home()
  ll.umount()
  love.event.push('quit', 'restart')
end

ll.dt = false
function ll.devtools()
  if not ll.dt then
    ll.dt = true
    __LL = ll
    pcall(function() require 'dev.tools' end)
  end
end

return ll
