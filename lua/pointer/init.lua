local nvim = vim.api -- luacheck: ignore
local utils = require("pointer.utils")

local default_mapping = {
  url = {"yu", [[require("pointer").bind("from_cursor", "url", "to_clip")]]},
  rel = {"yrp", [[require("pointer").bind("from_cursor", "path.relative_path", "to_clip")]]},
  proj = {"ypp", [[require("pointer").bind("from_cursor", "path.project_path", "to_clip")]]},
  root = {"yRp", [[require("pointer").bind("from_cursor", "path.root_path", "to_clip")]]},
}

local pointer = {
  collectors = require("pointer.collectors"),
  sinks = require("pointer.sinks"),
  formatters = require("pointer.formatters"),
  sources = {},
  data = {},
}

pointer.projfn = function()
  local path = nvim.nvim_call_function("getcwd", {})
  local buff = {}
  path:gsub("([^/]+)", function(p)
    table.insert(buff, p)
  end)
  return buff
end

pointer.sources.from_cursor = {
  project = pointer.projfn,
  file = pointer.collectors.file.current,
  line_number = pointer.collectors.line.current,
}

pointer.sources.from_motion = {
  project = pointer.projfn,
  file = pointer.collectors.file.current,
  line_number = pointer.collectors.line.from_opfunc,
}

pointer.sources.from_visual = {
  project = pointer.projfn,
  file = pointer.collectors.file.current,
  line_number = pointer.collectors.line.from_visual,
}

pointer.definition = function(project)
  return utils.get(pointer.data, project[#project]) or
         utils.get(pointer.data, project[#project-1]) or
         pointer.data
end

pointer.bind = function(source, formatter, sink)
  local sources = utils.get_in(pointer, {"sources", source})
  local data = {}
  for key, srcfn in pairs(sources) do
    data[key] = srcfn()
  end

  local definition = pointer.definition(data.project)
  local format = utils.get(definition, formatter) or utils.get_qualified(pointer, "formatters." .. formatter)
  local lsink = utils.get_in(pointer, {"sinks", sink})

  lsink(format(data))
end

pointer.config = function(config)
  pointer.data = utils.safe_merge({}, config)
end

pointer.map = function(mapping)
  local mappings = utils.safe_merge(default_mapping, mapping)
  for _, map in pairs(mappings) do
    nvim.nvim_command("nmap <silent> " .. map[1] .. " <Cmd> lua " .. map[2] .. "<CR>")
  end
end

return pointer
