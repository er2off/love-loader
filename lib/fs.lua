return function(ll)

function ll.fsIsAbs(f)
  f = f:sub(1, 1)
  return f == '/' or f == '\\'
end

function ll.fsIsRel(f)
  return not ll.fsIsAbs(f)
end

function ll.fsFile(f)
  return f:match '([^/\\]*)[/\\]*$'
end

function ll.fsDir(f)
  return f:match '^(.*)[/\\]+[^/\\]*[/\\]*$'
end

end
