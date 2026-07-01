local M = {}

-- Built-in toggles with special behavior (not env-driven)
M.toggles = {
  hidden    = true,  -- default includes --hidden
  gitignore = true,  -- respect .gitignore by default
}

-- Custom toggles loaded from env vars / defaults (populated by load_env_toggles)
-- Each entry: { key = "TESTS", pattern = "...", lua_patterns = {...}, enabled_text = "...", disabled_text = "...", keybind = "<C-t>", state = false }
M.custom_toggles = {}

local defaults = require('myLuaConf.plugins.telescope.default_env')

-- Read a toggle's fields from env vars, falling back to defaults
local function toggle_from_env(name)
  local pattern_key = "TELESCOPE_" .. name .. "_PATTERN"
  local pattern = vim.env[pattern_key] or defaults[pattern_key]
  if not pattern then return nil end

  local lua_pattern_key = "TELESCOPE_" .. name .. "_LUA_PATTERNS"
  local lua_raw = vim.env[lua_pattern_key] or defaults[lua_pattern_key]
  local lua_patterns = {}
  if lua_raw then
    for p in lua_raw:gmatch("[^,]+") do
      table.insert(lua_patterns, p)
    end
  end

  local enabled_text_pattern = "TELESCOPE_" .. name .. "_ENABLED_TEXT"
  local enabled_text = vim.env[enabled_text_pattern] or defaults[enabled_text_pattern] or ("See " .. name)

  local disabled_text_pattern = "TELESCOPE_" .. name .. "_DISABLED_TEXT"
  local disabled_text = vim.env[disabled_text_pattern] or defaults[disabled_text_pattern] or ("No " .. name)

  local keybind_pattern = "TELESCOPE_" .. name .. "_KEYBIND"
  local keybind = vim.env[keybind_pattern] or defaults[keybind_pattern]

  local default_pattern = "TELESCOPE_" .. name .. "_DEFAULT"
  local default_val = vim.env[default_pattern] or defaults[default_pattern]
  local state = default_val == "on"

  return {
    key = name,
    pattern = pattern,
    lua_patterns = lua_patterns,
    enabled_text = enabled_text,
    disabled_text = disabled_text,
    keybind = keybind,
    state = state,
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

-- Toggle state by keybind, return the toggle's name
function M.toggle_by_keybind(keybind)
  for _, t in ipairs(M.custom_toggles) do
    if t.keybind == keybind then
      t.state = not t.state
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
    table.insert(parts, t.state and t.enabled_text or t.disabled_text)
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

  -- Custom toggles (state=false means exclude)
  for _, t in ipairs(M.custom_toggles) do
    if not t.state then
      table.insert(args, "--glob")
      table.insert(args, "!" .. t.pattern)
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
    if not t.state then
      table.insert(find_command, "--glob")
      table.insert(find_command, "!" .. t.pattern)
    end
  end

  return find_command
end

-- Build file_ignore_patterns for LSP pickers based on current toggle state
function M.build_file_ignore_patterns()
  local patterns = {}
  for _, t in ipairs(M.custom_toggles) do
    if not t.state then
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
