-- luacheck: globals vim

local pointer = {}

pointer.config = {
	_cache = {},
}

pointer.setup = function(opts)
	pointer.config._cache = vim.tbl_extend("keep", {}, opts, pointer.config._cache)

	vim.keymap.set({ "n", "v" }, "yU", pointer.setreg, {})
	vim.keymap.set({ "n" }, "yu", function()
		vim.go.operatorfunc = "v:lua.require'pointer'.setreg"
		return "g@"
	end, { expr = true })
end

pointer.calculate_target = function(root)
	local remotes = vim.system({
		"git",
		"remote",
		"get-url",
		-- NOTE: Assumption that upstream url is named origin
		"origin",
	}, {
		cwd = root,
	})
		:wait().stdout
	local target = vim.split(remotes, "%.?git[^h]", { trimempty = true })[1]
	target = target:gsub(":", "/")
	pointer.config._cache[root] = target
	return target
end

pointer.locate = function(type)
	local result = vim.api.nvim_get_mode()
	local blocking = result.blocking

	if blocking then
		return
	end

	local file = vim.fn.expand("%:p")
	local base = vim.fn.expand("%:p:h")
	-- NOTE: Only supports git for now
	local root = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }, {
		cwd = base,
	})
		:wait().stdout)

	local target = pointer.config._cache[root]
	if target == nil then
		target = pointer.calculate_target(root)
	end

	local branch = vim.trim(vim.system({ "git", "branch", "--show-current" }, { cwd = root }):wait().stdout)

	if vim.startswith(file, root) ~= true then
		vim.notify("File does not belong to git repo, somehow", vim.log.levels.ERROR)
		return
	end

	local path = file:sub(#root + 2)

	local pos
	if type == nil then
		pos = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), { type = "v" })
	else
		pos = vim.fn.getregionpos(vim.api.nvim_buf_get_mark(0, "["), vim.api.nvim_buf_get_mark(0, "]"), { type = "v" })
	end

	local first = pos[1][1][2]
	local last = pos[#pos][2][2]

	vim.api.nvim_input("<ESC>")

	return { target, branch, path, first, last }
end

pointer.format = function(data)
	local url
	local suffix
	-- NOTE: Only githumb remote is supported
	if vim.startswith(data[1], "github.com") then
		join = "#"
		url = vim.iter({ "https:/", data[1], "tree", data[2], data[3] }):join("/")
		suffix = "L" .. data[4]
		if data[5] ~= nil and data[5] ~= data[4] then
			suffix = suffix .. "-L" .. data[5]
		end

		return url .. "#" .. suffix
	end
end

pointer.setreg = function(type)
	local data = pointer.locate(type)
	vim.fn.setreg(vim.v.register, pointer.format(data))
end

return pointer
