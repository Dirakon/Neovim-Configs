return {
  -- This works for ripgrep-based pickers:
  TELESCOPE_TESTS_PATTERN = "**/tests/**",
  -- alternatively:
  -- TELESCOPE_TESTS_PATTERNS_0 = "**/tests/**",
  -- TELESCOPE_TESTS_PATTERNS_1 = -- something else

  -- This works for lsp pickers:
  TELESCOPE_TESTS_LUA_PATTERNS = "/tests/,tests\\",
  TELESCOPE_TESTS_INCLUDE_TEXT = "See [T]ests",
  TELESCOPE_TESTS_EXCLUDE_TEXT = "No [T]ests",
  TELESCOPE_TESTS_ONLY_TEXT = "Only [T]ests",
  TELESCOPE_TESTS_KEYBIND = "<C-t>",
  TELESCOPE_TESTS_DEFAULT = "include",
  TELESCOPE_TESTS_MODES = "include, exclude, only",
}
