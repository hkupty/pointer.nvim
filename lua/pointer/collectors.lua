-- luacheck: globals vim
local utils = require("pointer.utils")
local collectors = {
  project = {},
  gitref = {},
  remote = {},
  file = {},
  line = {}
}

collectors.project.current = function()
  -- Assumption: project folders are saved as owner/project.
  return utils.last_n(utils.split_path(vim.fn.systemlist("git rev-parse --show-toplevel")[1]), 2)
end

collectors.gitref.head = function()
  return vim.fn.systemlist{"git", "rev-parse", "--abbrev-ref", "HEAD"}[1]
end

collectors.remote.named = function(name)
  local url = vim.fn.systemlist{"git", "remote", "get-url", name}[1]
  local remote
  string.gsub(url, "@([^:]+):", function(s) remote = s end)
  return string.match(remote, "([^.]+).(.*)")
end

collectors.remote.origin = function() return collectors.remote.named("origin") end

collectors.file.current = function()
  return vim.api.nvim_buf_get_name(0)
end

collectors.line.current = function()
  return vim.api.nvim_win_get_cursor(0)[1]
end

collectors.line.from_opfunc = function()
  return {
    vim.api.nvim_buf_get_mark(0, "[")[1],
    vim.api.nvim_buf_get_mark(0, "]")[1],
  }
end

collectors.line.from_visual = function()
  return {
    vim.fn.getpos('v')[2],
    vim.fn.getpos('.')[2],
  }
end



return collectors
