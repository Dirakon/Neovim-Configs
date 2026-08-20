local M = {}

-- Built-in toggles with special behavior (not env-driven)
M.toggles = {
  hidden    = true,  -- default includes --hidden
  gitignore = true,  -- respect .gitignore by default
}

-- Custom toggles loaded from env vars / defaults (populated by load_env_toggles)
-- Each entry: {
--   key          = "TESTS",
--   patterns     = { "**/tests/**" },          -- ripgrep globs
--   lua_patterns = { "/tests/" },              -- lua patterns for LSP pickers
--   mode_texts   = { include = "See [T]ests", exclude = "No [T]ests", only = "Only [T]ests" },
--   keybind      = "<C-t>",
--   modes        = { "include", "exclude", "only" },  -- ordered set of allowed modes
--   mode_index   = 1,                          -- pointer into `modes`
-- }
--
-- Mode semantics:
--   include = the regex/glob is ignored (everything is kept)
--   exclude = a file path must NOT match the regexes (ripgrep `--glob !p`,
--             LSP `file_ignore_patterns`)
--   only    = a file path MUST match the regexes (ripgrep `--glob p`; for LSP
--             pickers a best-effort entry filter is applied when possible)
M.custom_toggles = {}

local defaults = require('myLuaConf.plugins.telescope.default_env')

-- The three modes with defined semantics. The user may select any ordered
-- subset of these via TELESCOPE_<NAME>_MODES.
local KNOWN_MODES = { include = true, exclude = true, only = true }

-- Fallback status text for a mode when no *_TEXT env var is defined.
local DEFAULT_TEXT = {
  include = function(name) return "See " .. name end,
  exclude = function(name) return "No " .. name end,
  only    = function(name) return "Only " .. name end,
}

-- Read a toggle's fields from env vars, falling back to defaults
local function toggle_from_env(name)
  -- Collect numbered PATTERNS_x (x is a number) from defaults, then let env override per-index
  local collected = {}
  for k, v in pairs(defaults) do
    local n = k:match("^TELESCOPE_" .. name .. "_PATTERNS_(%d+)$")
    if n and v and v ~= "" then
      collected[tonumber(n)] = v
    end
  end
  for k, v in pairs(vim.fn.environ()) do
    local n = k:match("^TELESCOPE_" .. name .. "_PATTERNS_(%d+)$")
    if n and v and v ~= "" then
      collected[tonumber(n)] = v
    end
  end

  local pattern_key = "TELESCOPE_" .. name .. "_PATTERN"
  local single_pattern = vim.env[pattern_key] or defaults[pattern_key]

  local patterns = {}
  if next(collected) ~= nil then
    -- PATTERNS_x overrides single PATTERN
    local indices = {}
    for idx in pairs(collected) do table.insert(indices, idx) end
    table.sort(indices)
    for _, idx in ipairs(indices) do
      table.insert(patterns, collected[idx])
    end
  elseif single_pattern then
    patterns = { single_pattern }
  else
    return nil
  end

  local lua_pattern_key = "TELESCOPE_" .. name .. "_LUA_PATTERNS"
  local lua_raw = vim.env[lua_pattern_key] or defaults[lua_pattern_key]
  local lua_patterns = {}
  if lua_raw then
    for p in lua_raw:gmatch("[^,]+") do
      table.insert(lua_patterns, p)
    end
  end

  -- Per-mode status text. Each is optional; missing ones get a fallback.
  local mode_texts = {}
  for mode, _ in pairs(KNOWN_MODES) do
    local text_key = "TELESCOPE_" .. name .. "_" .. mode:upper() .. "_TEXT"
    mode_texts[mode] = vim.env[text_key] or defaults[text_key] or DEFAULT_TEXT[mode](name)
  end

  -- Ordered set of allowed modes (defaults to the full set).
  local modes_key = "TELESCOPE_" .. name .. "_MODES"
  local modes_raw = vim.env[modes_key] or defaults[modes_key] or "include, exclude, only"
  local modes = {}
  for mode in modes_raw:gmatch("[^,]+") do
    mode = mode:match("^%s*(.-)%s*$")  -- trim
    if KNOWN_MODES[mode] then
      table.insert(modes, mode)
    end
  end
  if #modes == 0 then
    modes = { "include" }
  end

  -- Starting mode (defaults to the first allowed mode).
  local default_key = "TELESCOPE_" .. name .. "_DEFAULT"
  local default_val = vim.env[default_key] or defaults[default_key] or modes[1]

  local mode_index = 1
  for i, mode in ipairs(modes) do
    if mode == default_val then
      mode_index = i
      break
    end
  end

  local keybind_pattern = "TELESCOPE_" .. name .. "_KEYBIND"
  local keybind = vim.env[keybind_pattern] or defaults[keybind_pattern]

  return {
    key          = name,
    patterns     = patterns,
    lua_patterns = lua_patterns,
    mode_texts   = mode_texts,
    keybind      = keybind,
    modes        = modes,
    mode_index   = mode_index,
  }
end

-- Populate M.custom_toggles from defaults + env var overrides
function M.load_env_toggles()
  -- Start with default toggle names
  local seen = {}
  for k, _ in pairs(defaults) do
    local name = k:match("^TELESCOPE_(%w+)_PATTERN$")
    if name then
      seen[name] = true
    end
    -- Discover toggles that define numbered PATTERNS_x
    name = k:match("^TELESCOPE_(%w+)_PATTERNS_%d+$")
    if name then
      seen[name] = true
    end
    -- Also discover toggles that only define a DEFAULT (no PATTERN)
    name = k:match("^TELESCOPE_(%w+)_DEFAULT$")
    if name then
      seen[name] = true
    end
  end

  -- Discover additional toggles from env vars
  for k, v in pairs(vim.fn.environ()) do
    local name = k:match("^TELESCOPE_(%w+)_PATTERN$")
    if name and v and v ~= "" then
      seen[name] = true
    end
    name = k:match("^TELESCOPE_(%w+)_PATTERNS_%d+$")
    if name and v and v ~= "" then
      seen[name] = true
    end
    name = k:match("^TELESCOPE_(%w+)_DEFAULT$")
    if name and v and v ~= "" then
      seen[name] = true
    end
  end

  for name, _ in pairs(seen) do
    local toggle = toggle_from_env(name)
    if toggle then
      table.insert(M.custom_toggles, toggle)
    end
  end

  -- Sort for deterministic order (alphabetical by key)
  table.sort(M.custom_toggles, function(a, b) return a.key < b.key end)
end

-- Current mode of a toggle
local function current_mode(t)
  return t.modes[t.mode_index]
end

-- Cycle a toggle's mode by keybind, advancing to the next allowed mode (wraps
-- around). Returns the toggle's key, or nil if no toggle matched.
function M.cycle_by_keybind(keybind)
  for _, t in ipairs(M.custom_toggles) do
    if t.keybind == keybind then
      t.mode_index = (t.mode_index % #t.modes) + 1
      return t.key
    end
  end
  return nil
end

-- Get list of custom keybinds for dynamic keymap attachment
function M.get_custom_keybinds()
  local result = {}
  for _, t in ipairs(M.custom_toggles) do
    if t.keybind then
      table.insert(result, { keybind = t.keybind, key = t.key })
    end
  end
  return result
end

-- Build a visual status string for the prompt_title
function M.status_line()
  local parts = {}
  for _, t in ipairs(M.custom_toggles) do
    table.insert(parts, t.mode_texts[current_mode(t)])
  end

  if M.toggles.hidden then    table.insert(parts, "See [H]idden")   end
  if not M.toggles.hidden then    table.insert(parts, "No [H]idden")   end

  if M.toggles.gitignore then table.insert(parts, "Respect [G]itignore") end
  if not M.toggles.gitignore then table.insert(parts, "Ignore [G]itignore") end
  return " [" .. table.concat(parts, " | ") .. "]"
end

-- Build vimgrep_arguments based on current toggle state
function M.build_vimgrep_args()
  local telescopeConfig = require("telescope.config")
  local args = { unpack(telescopeConfig.values.vimgrep_arguments) }

  if M.toggles.hidden then
    local has_hidden = false
    for _, v in ipairs(args) do
      if v == "--hidden" then has_hidden = true; break end
    end
    if not has_hidden then table.insert(args, "--hidden") end
  else
    for i = #args, 1, -1 do
      if args[i] == "--hidden" then table.remove(args, i) end
    end
  end

  -- Always exclude .git
  table.insert(args, "--glob")
  table.insert(args, "!**/.git/*")

  if not M.toggles.gitignore then
    table.insert(args, "--no-ignore")
  end

  for _, t in ipairs(M.custom_toggles) do
    local mode = current_mode(t)
    for _, p in ipairs(t.patterns) do
      if mode == "exclude" then
        table.insert(args, "--glob")
        table.insert(args, "!" .. p)
      elseif mode == "only" then
        table.insert(args, "--glob")
        table.insert(args, p)
      end
      -- include: glob is ignored
    end
  end

  return args
end

-- Build find_command for find_files based on current toggle state
function M.build_find_command()
  local find_command = { "rg", "--files" }

  if M.toggles.hidden then
    table.insert(find_command, "--hidden")
  end

  -- Always exclude .git
  table.insert(find_command, "--glob")
  table.insert(find_command, "!**/.git/*")

  if not M.toggles.gitignore then
    table.insert(find_command, "--no-ignore")
  end

  for _, t in ipairs(M.custom_toggles) do
    local mode = current_mode(t)
    for _, p in ipairs(t.patterns) do
      if mode == "exclude" then
        table.insert(find_command, "--glob")
        table.insert(find_command, "!" .. p)
      elseif mode == "only" then
        table.insert(find_command, "--glob")
        table.insert(find_command, p)
      end
    end
  end

  return find_command
end

-- Build file_ignore_patterns for LSP pickers (the `exclude` mode).
function M.build_file_ignore_patterns()
  local patterns = {}
  for _, t in ipairs(M.custom_toggles) do
    if current_mode(t) == "exclude" then
      for _, p in ipairs(t.lua_patterns) do
        table.insert(patterns, p)
      end
    end
  end
  return patterns
end

-- Initialize on load
M.load_env_toggles()

return M
