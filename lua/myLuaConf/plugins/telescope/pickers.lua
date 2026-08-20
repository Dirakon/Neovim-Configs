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
      toggles.cycle_by_keybind(kb.keybind)
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
      toggles.cycle_by_keybind(kb.keybind)
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
-- live_grep with --multiline (regex mode, no --fixed-strings)
-------------------------------------------------------------------
function M.live_grep_multiline(opts)
  opts = opts or {}

  local args = toggles.build_vimgrep_args()
  table.insert(args, '--multiline')

  builtin.live_grep(vim.tbl_extend("force", opts, {
    vimgrep_arguments = args,
    prompt_title = "Live Grep (multiline)" .. toggles.status_line(),
    attach_mappings = function(_, map)
      return attach_file_toggles(map, M.live_grep_multiline, opts)
    end,
  }))
end

-------------------------------------------------------------------
-- Grep visual selection with exact match + toggles
-- Handles multiline selections by converting newlines to \n escape
-- sequences and passing --multiline to ripgrep.
-------------------------------------------------------------------
function M.grep_visual_selection(opts)
  -- Save and restore register
  local saved_reg = vim.fn.getreg('z')
  local saved_regtype = vim.fn.getregtype('z')
  vim.cmd('noautocmd normal! "zy')
  local selection = vim.fn.getreg('z')
  vim.fn.setreg('z', saved_reg, saved_regtype)

  opts = opts or {}

  if selection:find('\n') then
    -- For multiline searches we need --multiline and cannot use
    -- --fixed-strings (it's incompatible with \n matching across lines
    -- in ripgrep). Escape regex special chars instead.
    -- Escape backslashes first, then other special chars, then convert
    -- newlines to \n so telescope's single-line prompt buffer can display them.
    selection = selection:gsub('\\', '\\\\')
    selection = selection:gsub('([%(%)%.%%%+%-%*%?%[%]%^%$%{%}%|])', '\\%1')
    selection = selection:gsub('\n', '\\n')
    -- Trim trailing \n from the visual selection (trailing newline artifact)
    selection = selection:gsub('\\n$', '')

    opts.default_text = selection
    M.live_grep_multiline(opts)
  else
    opts.default_text = selection
    M.live_grep_exact(opts)
  end
end

-------------------------------------------------------------------
-- Paste from clipboard into a telescope prompt, handling multiline text
-------------------------------------------------------------------
function M.paste_into_prompt()
  local text = vim.fn.getreg('+')
  if text == '' then return end

  local is_multiline = text:find('\n') ~= nil
  if not is_multiline then
    -- Single-line: just set the prompt text
    local action_state = require('telescope.actions.state')
    local picker = action_state.get_current_picker(vim.api.nvim_get_current_buf())
    local current = picker:_get_prompt()
    picker:set_prompt(current .. text, false)
    return
  end

  -- Multiline paste — check if we should upgrade live_grep_exact to
  -- live_grep_multiline (only when the prompt is empty/whitespace)
  local action_state = require('telescope.actions.state')
  local prompt_bufnr = vim.api.nvim_get_current_buf()
  local picker = action_state.get_current_picker(prompt_bufnr)
  local current_prompt = picker:_get_prompt()

  if current_prompt:match('^%s*$') and picker.prompt_title:find('^Live Grep %(exact%)') then
    -- Prompt is empty and we're in live_grep_exact: upgrade to multiline
    actions.close(prompt_bufnr)

    -- Escape for regex mode (same as grep_visual_selection)
    local escaped = text:gsub('\\', '\\\\')
    escaped = escaped:gsub('([%(%)%.%%%+%-%*%?%[%]%^%$%{%}%|])', '\\%1')
    escaped = escaped:gsub('\n', '\\n')
    escaped = escaped:gsub('\\n$', '')

    M.live_grep_multiline({ default_text = escaped })
  else
    -- Just convert newlines and paste into current prompt
    local converted = text:gsub('\n', '\\n')
    converted = converted:gsub('\\n$', '')
    picker:set_prompt(current_prompt .. converted, false)
  end
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
