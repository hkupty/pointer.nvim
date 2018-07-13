local nvim = vim.api -- luacheck: ignore
local sinks = {}

sinks.to_clip = function(val)
  nvim.nvim_call_function("setreg", {"+", val})
end

sinks.to_browser = function(val)
  nvim.nvim_command("!xdg-open '" .. val .. "'")
end

return sinks
