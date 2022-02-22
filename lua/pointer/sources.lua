local collectors = require("pointer.collectors")
local sources = {}

sources.from_cursor = {
  project = collectors.project.current,
  gitref = collectors.gitref.head,
  remote = collectors.remote.origin,
  file = collectors.file.current,
  line_number = collectors.line.current,
}

sources.from_motion = {
  project = collectors.project.current,
  gitref = collectors.gitref.head,
  remote = collectors.remote.origin,
  file = collectors.file.current,
  line_number = collectors.line.from_opfunc,
}

sources.from_visual = {
  project = collectors.project.current,
  gitref = collectors.gitref.head,
  remote = collectors.remote.origin,
  file = collectors.file.current,
  line_number = collectors.line.from_visual,
}

return sources
