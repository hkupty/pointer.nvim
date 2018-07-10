local nvim = vim.api -- luacheck: ignore
local collectors = {}

collectors.current_file = function()
  return nvim.nvim_call_function("expand", {"%:~:."})
end

collectors.current_line = function()
  return nvim.nvim_call_function("line", {"."})
end

collectors.lines_from_marks = function()
  return {
    nvim.nvim_buf_get_mark(".", "'<")[1],
    nvim.nvim_buf_get_mark(".", "'>")[1],
  }
end

return collectors
