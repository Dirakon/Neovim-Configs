vim.keymap.set({"n", "v", "x"}, '<leader>y', '"+y', { noremap = true, silent = true, desc = '[Y]ank to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<C-a>', 'gg0vG$', { noremap = true, silent = true, desc = 'Select all' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = '[P]aste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+',
	{ noremap = true, silent = true, desc = '[P]aste from clipboard from within insert mode' })
vim.keymap.set("x", "<leader>P", '"_dP',
	{ noremap = true, silent = true, desc = '[P]aste over selection without erasing unnamed register' })
