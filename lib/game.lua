return function(ll)

ll.games = {}

local function parse(conf)
  local r = {}
  local k, v

  local buf = ''
  local t = 'str'
  local esc = false
  local prg = true

  local i = 1
  repeat
    local ch = conf:sub(i, i)

    if ch == '\\'
    then esc = true

    elseif ch == '#' then
      repeat i = i + 1
        ch = conf:sub(i, i)
      until ch == '' or ch == '\n' or ch == '\r'

    elseif ch == '[' then
      buf = buf:match '%s*(.*)%s*'
      assert(#buf == 0, 'Unexpected array usage')
      t = 'arr'
      prg = true
      v = {}

    elseif ch == ''
    or (ch == '=' and not k)
    or (ch == ']' and t == 'arr')
    or (ch == ';' and t == 'arr')
    or ch == '\n' or ch == '\r' then
      buf = buf:match '^%s*(.-)%s*$'

      if ch == '=' then
        assert(t == 'str', 'Cannot use other types than string for key')
      end

      if t == 'str'
      or (t == 'arr' and ch == ']')
      then prg = false end

      if not prg or ch == ';' then
        if #buf ~= 0 then
          if k then
            if t == 'str'
            then v = buf
            elseif t == 'arr'
            then table.insert(v, buf)
            else error 'wut?' end
          else k = buf
          end
          buf = ''
        elseif ch ~= ''
        and ch ~= '\r'
        and ch ~= '\n'
        then error 'empty buffer'
        end
      end
      if k and v and not prg then
        r[k] = v
        k = nil
        v = nil
        buf = ''
        t = 'str'
      end

    elseif esc then
      buf = buf .. ch
      esc = false

    else buf = buf .. ch
    end
    i = i + 1
  until i >= #conf + 1
  return r
end

function ll.gameNew(conf, file, base, dir)
  local cfg = parse(conf or '')
  local gme = {
    name = cfg.name or dir or 'No name',
    desc = cfg.desc or 'No description provided.',
    base = base,
    dir = dir,
    main = cfg.main or 'main.lua',
    screens = cfg.screens or cfg.pics or nil,
    scrcur = 1,
    scrprv = 1,
    dat = nil,
  }
  return gme
end

end
