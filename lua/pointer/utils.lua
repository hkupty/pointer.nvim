local nvim = vim.api -- luacheck: ignore
local utils = {}

utils.merge = function(curr, new)
  for k, v in pairs(new) do
    curr[k] = v
  end

  return curr
end

utils.safe_merge = function(a, b)
  return utils.merge(utils.merge({}, a), b)
end

utils.get = function(d, k)
  return d and d[k]
end

utils.get_in = function(d, k)
  local p = d
  for _, i in ipairs(k) do
    p = utils.get(p, i)
  end

  return p
end

utils.get_qualified = function(d, p)
  local buff = {}
  p:gsub("([^.]+)", function(i) table.insert(buff, i) end)
  return utils.get_in(d, buff)
end

return utils
