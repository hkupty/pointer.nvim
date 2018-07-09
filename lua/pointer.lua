local nvim = vim.api -- luacheck: ignore
local pointer = {
  data = {},
  internal = {},
  path = {}
}

pointer.internal.merge = function(curr, new)
  for k, v in pairs(new) do
    curr[k] = v
  end

  return curr
end

pointer.internal.safe_merge = function(a, b)
  return pointer.internal.merge(pointer.internal.merge({}, a), b)
end

pointer.internal.get = function(d, k)
  return d and d[k]
end

pointer.internal.get_in = function(d, k)
  local p = d
  for _, i in ipairs(k) do
    p = pointer.internal.get(p, i)
  end

  return p
end

local defaults = {
  url_sep = "/",
  sep = "#",
  base_url = "",
  projfn = function()
    local path = nvim.nvim_call_function("getcwd", {})
    local buff = {}
    path:gsub("([^/]+)", function(p)
      table.insert(buff, p)
    end)
    return buff
  end
}

local default_mapping = {
  url = {"yu", [[require("pointer").to_clip(require("pointer").url())]]},
  rel = {"yrp", [[require("pointer").to_clip(require("pointer").path.rel())]]},
  proj = {"ypp", [[require("pointer").to_clip(require("pointer").path.proj())]]},
  root = {"yRp", [[require("pointer").to_clip(require("pointer").path.root())]]},
}

pointer.at = function()
  return nvim.nvim_call_function("line", {"."})
end

pointer.curr_file = function()
  return nvim.nvim_call_function("expand", {"%"})
end

pointer.internal.for_proj = function(project, o)
  return pointer.internal.get_in(pointer.data, {project[#project], o}) or
         pointer.internal.get_in(pointer.data, {project[#project-1], o}) or
         pointer.internal.get(pointer.data, o)
end

pointer.internal.urlroot = function(project)
  return pointer.internal.for_proj(project, "base_url")
end

pointer.internal.sep = function(project)
  return pointer.internal.for_proj(project, "sep")
end

pointer.internal.url_sep = function(project)
  return pointer.internal.for_proj(project, "url_sep")
end

pointer.url = function(fn, ln)
  local file = fn or pointer.curr_file()
  local number = ln or pointer.at()
  local project = pointer.data.projfn()
  local urlroot = pointer.internal.urlroot(project)
  local sep = pointer.internal.sep(project)
  local url_sep = pointer.internal.url_sep(project)

  return  urlroot .. project[#project] .. url_sep .. file .. sep .. number
end

pointer.internal.path = function(fn, ln)
  return {
   file = fn or pointer.curr_file(),
   number = ln or pointer.at(),
   project = pointer.data.projfn()
}
end

pointer.path.root = function(fn, ln)
  local path = pointer.internal.path(fn, ln)

  local full = path.project
  table.insert(full, path.file)

  return "/" .. table.concat(full, "/") .. " +" .. path.number
end

pointer.path.proj = function(fn, ln)
  local path = pointer.internal.path(fn, ln)

  local full = {path.project[#path.project]}
  table.insert(full, path.file)

  return table.concat(full, "/") .. " +" .. path.number
end

pointer.path.rel = function(fn, ln)
  local path = pointer.internal.path(fn, ln)

  return path.file .. " +" .. path.number
end

pointer.config = function(config)
  pointer.data = pointer.internal.safe_merge(defaults, config)
end

pointer.to_clip = function(val)
  nvim.nvim_call_function("setreg", {"+", val})
end


pointer.map = function(mapping)
  local mappings = pointer.internal.safe_merge(default_mapping, mapping)
  for _, map in pairs(mappings) do
    nvim.nvim_command("nmap <silent> " .. map[1] .. " <Cmd> lua " .. map[2] .. "<CR>")
  end
end

return pointer
