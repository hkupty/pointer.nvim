-- luacheck: globals vim
local formatters = {
  path = {},
  url = {}
}

local relative_path = function(data)
  local path = vim.split(data.file, data.project, { plain = true, trimempty = true })
  return path[#path]
end

formatters.path.root_path = function(data)
  return "/" .. data.file .. " +" .. data.line_number
end

formatters.path.project_path = function(data)
  return relative_path(data) .. " +" .. data.line_number
end

formatters.url.raw_git = function(url)
  return function(data)
    local ln
    if type(data.line_number) == "table" then
      ln = "#L" .. data.line_number[1] .. "-L" .. data.line_number[2]
    else
      ln = "#L" .. data.line_number
    end

    return (url
      .. data.remote_project
      .. "/blob/"
      .. data.gitref
      .. relative_path(data)
      .. ln)
  end
end

formatters.url.github = formatters.url.raw_git("https://github.com/")

formatters.url.gitlab = formatters.url.raw_git("https://gitlab.com/")

formatters.url.opengrok = function(baseurl)
  return function(data)
    local ln
    if type(data.line_number) == "table" then
      ln = "#" .. data.line_number[1] .. "-" .. data.line_number[2]
    else
      ln = "#" .. data.line_number
    end

    return baseurl .. data.project[#data.project] .. "/" .. data.file .. ln
  end
end

return formatters
