local nvim = vim.api -- luacheck: ignore
local formatters = {
  path = {},
  url = {}
}

formatters.path.root_path = function(data)
  local path = data.project
  table.insert(path, data.file)

  return "/" .. table.concat(path, "/") .. " +" .. data.number
end

formatters.path.project_path = function(data)
  local path = {data.project[#data.project]}
  table.insert(path, data.file)

  return table.concat(path, "/") .. " +" .. data.number
end

formatters.path.relative_path = function(data)
  return data.file .. " +" .. data.number
end

formatters.url.raw_git = function(url)
  return function(data)
    local ln = nil
    if type(data.line_number) == "table" then
      ln = "#L" .. data.line_number[1] .. "-L" .. data.line_number[2]
    else
      ln = "#L" .. data.line_number
    end

    return url .. data.project[#data.project-1] .. "/" .. data.project[#data.project] .. "/blob/master/" .. data.file .. ln
  end
end

formatters.url.github = formatters.url.raw_git("https://github.com/")

formatters.url.gitlab = formatters.url.raw_git("https://gitlab.com/")

formatters.url.opengrok = function(baseurl)
  return function(data)
    local ln = nil
    if type(data.line_number) == "table" then
      ln = "#" .. data.line_number[1] .. "-" .. data.line_number[2]
    else
      ln = "#" .. data.line_number
    end

    return baseurl .. data.project[#data.project] .. "/" .. data.file .. ln
  end
end

return formatters


