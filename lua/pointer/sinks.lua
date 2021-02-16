local sinks = {}

sinks.to_clip = function(val)
  vim.fn.setreg("+", val)
end

sinks.to_browser = function(val)
  vim.fn.system{"xdg-open", val}
end

return sinks
