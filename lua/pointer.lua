local nvim = vim.api -- luacheck: ignore

local defaults = {
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

local pointer = {
  data = {},
  internal = {},
  path = {},
  urls = {}
}

-- [[ Internal functions
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

pointer.internal.for_proj = function(project, o)
  return pointer.internal.get_in(pointer.data, {project[#project], o}) or
         pointer.internal.get_in(pointer.data, {project[#project-1], o}) or
         pointer.internal.get(pointer.data, o)
end

pointer.internal.path = function(fn, ln)
  return {
   file = fn or pointer.curr_file(),
   number = ln or pointer.at(),
   project = pointer.data.projfn()
}
end
-- ]]

-- [[ Local path

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

-- ]]

pointer.config = function(config)
  pointer.data = pointer.internal.safe_merge(defaults, config)
end

pointer.to_clip = function(val)
  nvim.nvim_call_function("setreg", {"+", val})
end

pointer.at = function()
  return nvim.nvim_call_function("line", {"."})
end

pointer.curr_file = function()
  return nvim.nvim_call_function("expand", {"%"})
end

pointer.urls.raw_git = function(url)
  return function(data)
    local ln = nil
    if type(data.line_number) == "table" then
      ln = "#L" .. data.line_number[1] .. "-L" .. data.line_number[2]
    else
      ln = "#L" .. data.line_number
    end

    return url .. data.ownername .. "/" .. data.projname .. "/blob/master/" .. data.fname .. ln
  end
end

pointer.urls.github = pointer.urls.raw_git("https://github.com/")

pointer.urls.gitlab = pointer.urls.raw_git("https://gitlab.com/")

pointer.urls.opengrok = function(baseurl)
  return function(data)
    local ln = nil
    if type(data.line_number) == "table" then
      ln = "#" .. data.line_number[1] .. "-" .. data.line_number[2]
    else
      ln = "#" .. data.line_number
    end

    return baseurl .. data.projname .. "/" .. data.fname .. ln
  end
end

pointer.url = function(fn, ln)
  local file = fn or pointer.curr_file()
  local number = ln or pointer.at()
  local project = pointer.data.projfn()
  local urlfn = pointer.internal.for_proj(project, "urlfn")

  return urlfn{
    project = project,
    ownername = project[#project-1],
    projname = project[#project],
    fname = file,
    line_number = number
  }

end

pointer.map = function(mapping)
  local mappings = pointer.internal.safe_merge(default_mapping, mapping)
  for _, map in pairs(mappings) do
    nvim.nvim_command("nmap <silent> " .. map[1] .. " <Cmd> lua " .. map[2] .. "<CR>")
  end
end

return pointer
