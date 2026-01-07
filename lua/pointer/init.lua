-- luacheck: globals vim

local pointer = {}

pointer.config = {}

pointer.setup = function(opts) end

pointer.locate = function()
	local mode, blocking = vim.api.nvim_get_mode()

	if blocking then
		return
	end

	local file = vim.fn.expand("%:p")
	local base = vim.fn.expand("%:p:h")
	local root = vim.trim(vim.system("git rev-parse --show-toplevel", {
		cwd = base,
	}))

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

	-- TODO: multi-line locate

	-- HACK: Fallback case, no line found
	return { path }
end

return pointer
