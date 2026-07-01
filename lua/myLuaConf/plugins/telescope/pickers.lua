local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local toggles = require('myLuaConf.plugins.telescope.toggles')

-- Read the current prompt text from a TelescopePrompt buffer
local function get_prompt_text(prompt_bufnr)
  local action_state = require('telescope.actions.state')
  return action_state.get_current_picker(prompt_bufnr):_get_prompt()
end

-- Shared toggle keymaps for file pickers (hidden, gitignore, custom toggles)
-- Captures prompt text BEFORE closing so it survives the reopen
local function attach_file_toggles(map, reopen_fn, opts)
  map("i", "<C-h>", function(prompt_bufnr)
    local prompt = get_prompt_text(prompt_bufnr)
    toggles.toggles.hidden = not toggles.toggles.hidden
    actions.close(prompt_bufnr)
    opts = vim.tbl_extend("force", opts, { default_text = prompt })
    reopen_fn(opts)
  end)
  map("i", "<C-g>", function(prompt_bufnr)
    local prompt = get_prompt_text(prompt_bufnr)
    toggles.toggles.gitignore = not toggles.toggles.gitignore
    actions.close(prompt_bufnr)
    opts = vim.tbl_extend("force", opts, { default_text = prompt })
    reopen_fn(opts)
  end)
  -- Dynamic custom toggle keymaps (loaded from env vars)
  for _, kb in ipairs(toggles.get_custom_keybinds()) do
    map("i", kb.keybind, function(prompt_bufnr)
      local prompt = get_prompt_text(prompt_bufnr)
      toggles.toggle_by_keybind(kb.keybind)
      actions.close(prompt_bufnr)
      opts = vim.tbl_extend("force", opts, { default_text = prompt })
      reopen_fn(opts)
    end)
  end
  return true
end

-- Toggle keymaps for LSP pickers (custom toggles from env vars)
local function attach_lsp_toggles(map, reopen_fn, opts)
  for _, kb in ipairs(toggles.get_custom_keybinds()) do
    map("i", kb.keybind, function(prompt_bufnr)
      local prompt = get_prompt_text(prompt_bufnr)
      toggles.toggle_by_keybind(kb.keybind)
      actions.close(prompt_bufnr)
      opts = vim.tbl_extend("force", opts, { default_text = prompt })
      reopen_fn(opts)
    end)
  end
  return true
end

-------------------------------------------------------------------
-- find_files with toggles
-------------------------------------------------------------------
local M = {}

function M.find_files(opts)
  opts = opts or {}

  builtin.find_files(vim.tbl_extend("force", opts, {
    find_command = toggles.build_find_command(),
    prompt_title = "Find Files" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_file_toggles(map, M.find_files, opts)
    end,
  }))
end

-------------------------------------------------------------------
-- live_grep with toggles (replaces both live_grep_exact and the
-- plain live_grep — toggle state controls all flags)
-------------------------------------------------------------------
function M.live_grep(opts)
  opts = opts or {}

  builtin.live_grep(vim.tbl_extend("force", opts, {
    vimgrep_arguments = toggles.build_vimgrep_args(),
    prompt_title = "Live Grep" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_file_toggles(map, M.live_grep, opts)
    end,
  }))
end

-------------------------------------------------------------------
-- live_grep with --fixed-strings (exact match)
-------------------------------------------------------------------
function M.live_grep_exact(opts)
  opts = opts or {}

  local args = toggles.build_vimgrep_args()
  table.insert(args, '--fixed-strings')

  builtin.live_grep(vim.tbl_extend("force", opts, {
    vimgrep_arguments = args,
    prompt_title = "Live Grep (exact)" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_file_toggles(map, M.live_grep_exact, opts)
    end,
  }))
end

-------------------------------------------------------------------
-- Grep visual selection with exact match + toggles
-------------------------------------------------------------------
function M.grep_visual_selection(opts)
  -- Save and restore register
  local saved_reg = vim.fn.getreg('z')
  local saved_regtype = vim.fn.getregtype('z')
  vim.cmd('noautocmd normal! "zy')
  local selection = vim.fn.getreg('z')
  vim.fn.setreg('z', saved_reg, saved_regtype)

  opts = opts or {}
  opts.default_text = selection

  M.live_grep_exact(opts)
end

-------------------------------------------------------------------
-- LSP pickers with custom toggle support
-------------------------------------------------------------------
function M.lsp_references(opts)
  opts = opts or {}
  local ignore_patterns = toggles.build_file_ignore_patterns()

  builtin.lsp_references(vim.tbl_extend("force", opts, {
    file_ignore_patterns = ignore_patterns,
    prompt_title = "References" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_lsp_toggles(map, M.lsp_references, opts)
    end,
  }))
end

function M.lsp_definitions(opts)
  opts = opts or {}
  local ignore_patterns = toggles.build_file_ignore_patterns()

  builtin.lsp_definitions(vim.tbl_extend("force", opts, {
    file_ignore_patterns = ignore_patterns,
    prompt_title = "Definitions" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_lsp_toggles(map, M.lsp_definitions, opts)
    end,
  }))
end

function M.lsp_type_definitions(opts)
  opts = opts or {}
  local ignore_patterns = toggles.build_file_ignore_patterns()

  builtin.lsp_type_definitions(vim.tbl_extend("force", opts, {
    file_ignore_patterns = ignore_patterns,
    prompt_title = "Type Definitions" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_lsp_toggles(map, M.lsp_type_definitions, opts)
    end,
  }))
end

function M.lsp_implementations(opts)
  opts = opts or {}
  local ignore_patterns = toggles.build_file_ignore_patterns()

  builtin.lsp_implementations(vim.tbl_extend("force", opts, {
    file_ignore_patterns = ignore_patterns,
    prompt_title = "Implementations" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_lsp_toggles(map, M.lsp_implementations, opts)
    end,
  }))
end

return M
