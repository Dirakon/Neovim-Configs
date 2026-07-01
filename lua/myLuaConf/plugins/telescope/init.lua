-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of help_tags options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {},
    },
    prompt_prefix = " ",
    selection_caret = " ",
    path_display = { "smart" },
    dynamic_preview_title = true,
    winblend = 0,
    sorting_strategy = "ascending",
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "bottom",
      height = 0.95,
    },
    vimgrep_arguments = {
      'rg',
      '--hidden',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
}

-- Enable telescope extensions, if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'live_grep_args')

-- Custom pickers with toggle support
local pickers = require('myLuaConf.plugins.telescope.pickers')
local builtin = require 'telescope.builtin'

-- File pickers
vim.keymap.set('n', '<leader>f', pickers.find_files, { desc = 'Select [F]ile' })
vim.keymap.set('n', '<leader>c', pickers.live_grep_exact, { desc = 'Find [C]ontent exact' })
vim.keymap.set('n', '<leader>C', require('telescope').extensions.live_grep_args.live_grep_args,
  { desc = 'Find [C]ontent configurable' })
vim.keymap.set('v', '<leader>c', pickers.grep_visual_selection,
  { desc = 'Find [C]ontent visually selected' })

-- Buffer / resume
local function buffers()
  builtin.buffers({ sort_mru = true })
end
vim.keymap.set('n', '<leader>b', buffers, { desc = 'Select [B]uffer' })
vim.keymap.set('n', '<leader>t', builtin.resume, { desc = 'Open previous [T]elescope picker' })

-- Symbol search
vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, { desc = 'Search local [S]ymbols' })
vim.keymap.set('n', '<leader>S', builtin.lsp_dynamic_workspace_symbols, { desc = 'Search workspace [S]ymbols' })

-- LSP navigation (with test-exclusion toggle)
vim.keymap.set('n', 'gr', pickers.lsp_references, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'gd', pickers.lsp_definitions, { desc = '[G]oto [D]efinitions' })
vim.keymap.set('n', 'gt', pickers.lsp_type_definitions, { desc = '[G]oto [T]ype definitions' })
vim.keymap.set('n', 'gi', pickers.lsp_implementations, { desc = '[G]oto [I]mplementation' })

-- Unmap annoying defaults
vim.keymap.del({ 'n' }, 'grr')
vim.keymap.del({ 'n' }, 'grt')
vim.keymap.del({ 'n' }, 'gra')
vim.keymap.del({ 'n' }, 'grn')
vim.keymap.del({ 'n' }, 'gri')

-- Telescope live_grep in git root
local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  if current_file == "" then
    current_dir = cwd
  else
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = { git_root },
    })
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
