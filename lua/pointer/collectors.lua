local nvim = vim.api -- luacheck: ignore
local collectors = {
  file = {},
  line = {}
}

collectors.file.current = function()
  return nvim.nvim_call_function("expand", {"%:~:."})
end

collectors.line.current = function()
  return nvim.nvim_call_function("line", {"."})
end

collectors.line.from_opfunc = function()
  return {
    nvim.nvim_buf_get_mark(".", "[")[1],
    nvim.nvim_buf_get_mark(".", "]")[1],
  }
end

collectors.line.from_visual = function()
  return {
    nvim.nvim_buf_get_mark(".", "<")[1],
    nvim.nvim_buf_get_mark(".", ">")[1],
  }
end

return collectors
