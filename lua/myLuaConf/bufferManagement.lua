local function save_buffer()
	vim.cmd 'w'
end
vim.keymap.set({ 'n' }, '<leader>w', save_buffer, { desc = '[W]rite (save) buffer' })

local function save_all_buffers()
	vim.cmd 'wa'
end
vim.keymap.set({ 'n' }, '<leader>w', save_all_buffers, { desc = '[W]rite (save) all buffers' })

local function switch_to_previous_buffer()
	vim.cmd 'b#'
end
vim.keymap.set('n', '<C-b>', switch_to_previous_buffer, { desc = 'Switch with last [B]uffer' })

local function close_buffer()
	vim.cmd 'bd'
end
vim.keymap.set('n', '<leader>x', close_buffer, { desc = 'Close buffer' })

local function force_close_buffer()
	vim.cmd 'bd!'
end
vim.keymap.set('n', '<leader>X', force_close_buffer, { desc = 'Force close buffer' })

local function close_other_buffers()
	vim.cmd 'BufOnly'
end
vim.keymap.set('n', '<leader><C-x>', close_other_buffers, { desc = 'Close other buffers' })
