local ll = {}

ll.cfg = {
  root = 'games/',
}

require 'lib.game'   (ll)
require 'lib.chroot' (ll)
require 'lib.load'   (ll)

function ll.home()
  ll.umount()
  error 'go to home'
end

if love then
  require 'lib.love.chroot' (ll)
  require 'lib.love.load'   (ll)

  function ll.home()
    ll.umount()
    love.event.push('quit', 'restart')
  end
  llHome = ll.home
end

return ll
