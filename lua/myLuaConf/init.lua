require("myLuaConf.plugins")
require("myLuaConf.LSPs")
require("myLuaConf.diagnostics")


local function save_file()
	vim.cmd 'w'
end
vim.keymap.set({'n'}, '<leader>w', save_file, { desc = '[W]rite file' })

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

-- Recomended settings for session restore stuff
vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Clipboard-related copy-paste
vim.keymap.set({"n", "v", "x"}, '<leader>y', '"+y', { noremap = true, silent = true, desc = '[Y]ank to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<C-a>', 'gg0vG$', { noremap = true, silent = true, desc = 'select all' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = '[P]aste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+',
	{ noremap = true, silent = true, desc = '[P]aste from clipboard from within insert mode' })
vim.keymap.set("x", "<leader>P", '"_dP',
	{ noremap = true, silent = true, desc = '[P]aste over selection without erasing unnamed register' })

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true -- Every wrapped line will continue visually indented (same amount of space as the beginning of that line)

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes' -- git-like file changes and stuff

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')


-- Neovide
if vim.g.neovide then
	vim.g.neovide_transparency = 0.7
	vim.g.neovide_scale_factor = 0.8
end

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})


-- Needs to be called after everything for https://github.com/Wansmer/langmapper.nvim to work!
require("myLuaConf.layouts")
