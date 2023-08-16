-- luacheck: globals vim
local utils = require("pointer.utils")
local sinks = require("pointer.sinks")
local formatters = require("pointer.formatters")
local sources = require("pointer.sources")


local pointer = {
  data = {}
}

pointer.definition = function(project)
  return utils.get(pointer.data, project[#project]) or
      utils.get(pointer.data, project[#project - 1]) or
      pointer.data
end


pointer.bind = function(opts)
  local source = opts.source or pointer.data.source or sources.from_cursor
  local sink = opts.sink or pointer.data.sink or sinks.to_clip
  local formatter = opts.formatter or pointer.data.formatter or formatters.url

  return function()
    pointer.run(source, formatter, sink)
  end
end

pointer.run = function(source, formatter, sink)
  local data = {}
  for key, srcfn in pairs(source) do
    data[key] = srcfn()
  end

  if type(formatter) == "table" then
    formatter = formatter[data.remote]
  end

  sink(formatter(data))
end

pointer.config = function(config)
  pointer.data = utils.safe_merge({}, config)
end

local default_mapping = {
  url = { "yu", formatters.url },
  proj = { "ypp", formatters.path.project_path },
  root = { "yRp", formatters.path.root_path },
}

pointer.setup = function(mapping)
  local mappings = utils.safe_merge(default_mapping, mapping or {})
  for _, map in pairs(mappings) do
    vim.keymap.set(
      { "n" },
      map[1],
      pointer.bind { formatter = map[2], source = sources.from_cursor },
      { silent = true }
    )

    vim.keymap.set(
      { "v" },
      map[1],
      pointer.bind { formatter = map[2], source = sources.from_visual },
      { silent = true }
    )
  end
end


return pointer
