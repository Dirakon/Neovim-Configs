local pos_equal = function(p1, p2)
	local r1, c1 = unpack(p1)
	local r2, c2 = unpack(p2)
	return r1 == r2 and c1 == c2
end

local goto_next_diagnostic_by_severity = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
	local pos2 = vim.api.nvim_win_get_cursor(0)
	if (pos_equal(pos, pos2)) then
		vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN, wrap = true })
		local pos3 = vim.api.nvim_win_get_cursor(0)
		if (pos_equal(pos, pos3)) then
			vim.diagnostic.goto_next({ wrap = true })
		end
	end
end

local goto_prev_diagnostic_by_severity = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
	local pos2 = vim.api.nvim_win_get_cursor(0)
	if (pos_equal(pos, pos2)) then
		vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN, wrap = true })
		local pos3 = vim.api.nvim_win_get_cursor(0)
		if (pos_equal(pos, pos3)) then
			vim.diagnostic.goto_prev({ wrap = true })
		end
	end
end

local goto_next_diagnostic = function()
	vim.diagnostic.goto_next({ wrap = true })
end

local goto_prev_diagnostic = function()
	vim.diagnostic.goto_prev({ wrap = true })
end

-- Some diagnostic navigation override -> https://github.com/neovim/neovim/discussions/25588
vim.keymap.set("n", '[d', goto_prev_diagnostic_by_severity,
	{ noremap = true, desc = 'Jump to previous [D]iagnostic (by severity)' })
vim.keymap.set("n", ']d', goto_next_diagnostic_by_severity,
	{ noremap = true, desc = 'Jump to next [D]iagnostic (by severity)' })
vim.keymap.set("n", '[D', goto_prev_diagnostic, { noremap = true, desc = 'Jump to previous [D]iagnostic (all)' })
vim.keymap.set("n", ']D', goto_next_diagnostic, { noremap = true, desc = 'Jump to next [D]iagnostic (all)' })
