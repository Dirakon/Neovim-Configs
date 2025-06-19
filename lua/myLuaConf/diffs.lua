function compare_buf_to_clipboard()
	local ftype = vim.api.nvim_eval("$filetype")
	vim.cmd(string.format[[
		vsplit
		enew
		normal! \"+P
		setlocal buftype=nowrite
		set filetype=%s
		diffthis
		execute "normal! \<C-w>h"
		diffthis
	]], ftype)
end
vim.keymap.set({'n'}, '<leader>D', compare_buf_to_clipboard, { 
	noremap = true,
	silent = false,
	desc = '[D]iff this buffer with clipboard' })

function compare_selection_to_clipboard()
	local ftype = vim.api.nvim_eval("$filetype")
	vim.cmd(string.format[[
		execute "normal! \"xy"
		vsplit
		enew
		normal! \"+P
		setlocal buftype=nowrite
		set filetype=%s
		diffthis
		execute "normal! \<C-w>\<C-w>"
		enew
		set filetype=%s
		execute "normal! \"xP"
		setlocal buftype=nowrite
		diffthis
	]], ftype, ftype)
end
vim.keymap.set({'x'}, '<leader>D', compare_selection_to_clipboard, {
	noremap = true,
	silent = false,
	desc = '[D]iff this selection with clipboard' })

