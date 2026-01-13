-- luacheck: globals vim

local pointer = {}

pointer.config = {
	_cache = {},
}

pointer.setup = function(opts)
	-- TODO: Make it an operator so this can be sent to a register instead
	-- NOTE: Possibly take register from v:register
	vim.keymap.set({ "n", "v" }, "yu", function()
		vim.fn.setreg("", pointer.format())
	end, {})
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

pointer.locate = function()
	local result = vim.api.nvim_get_mode()
	local mode = result.mode
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

	if vim.startswith(mode, "n") then
		local cursor = vim.api.nvim_win_get_cursor(0)

		-- NOTE: single-line locate
		return { target, branch, path, cursor[1] }
	end

	local pos = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), { type = "v" })
	local first = pos[1][1][2]
	local last = pos[#pos][2][2]

	-- TODO: multi-line locate

	-- HACK: Fallback case, no line found
	return { target, branch, path, first, last }
end

pointer.format = function()
	local data = pointer.locate()

	local url
	local suffix
	-- NOTE: Only githumb remote is supported
	if vim.startswith(data[1], "github.com") then
		join = "#"
		url = vim.iter({ "https:/", data[1], "tree", data[2], data[3] }):join("/")
		suffix = "L" .. data[4]
		if data[5] ~= nil then
			suffix = suffix .. "-L" .. data[5]
		end

		return url .. "#" .. suffix
	end
end

return pointer
