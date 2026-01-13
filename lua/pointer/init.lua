-- luacheck: globals vim

local pointer = {}

pointer.config = {}

pointer.setup = function(opts)
	vim.keymap.set({ "n", "v" }, "yu", pointer.locate, {})
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
	local root = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }, {
		cwd = base,
	})
		:wait().stdout)

	if vim.startswith(file, root) ~= true then
		vim.notify("File does not belong to git repo, somehow", vim.log.levels.ERROR)
		return
	end

	local path = file:sub(#root + 2)

	if vim.startswith(mode, "n") then
		local cursor = vim.api.nvim_win_get_cursor(0)

		-- NOTE: single-line locate
		return { path, cursor[1] }
	end

	local pos = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), { type = "v" })
	local first = pos[1][1][2]
	local last = pos[#pos][2][2]

	-- TODO: multi-line locate

	-- HACK: Fallback case, no line found
	return { path, first, last }
end

return pointer
