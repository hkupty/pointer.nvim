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
  return vim.fn.systemlist("git rev-parse --show-toplevel")[1]
end

collectors.project.remote = function()
  local url = vim.fn.systemlist { "git", "remote", "get-url", "origin" }[1]
  local remote
  local _ = string.gsub(url, "@[^:]+:(.+).git", function(s) remote = s end, 1)
  return remote
end

collectors.gitref.head = function()
  return vim.fn.systemlist { "git", "rev-parse", "--abbrev-ref", "HEAD" }[1]
end

collectors.remote.named = function(name)
  local url = vim.fn.systemlist { "git", "remote", "get-url", name }[1]
  local remote
  local _ = string.gsub(url, "@([^:]+):", function(s) remote = s end, 1)
  return string.match(remote, "([^.]+).*", 1)
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
