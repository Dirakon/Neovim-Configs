-- 1. Global defaults
vim.lsp.config('*', {
  capabilities = require('myLuaConf.LSPs.caps-on_attach').get_capabilities(),
  on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach,
})

-- 2. Simple servers (defaults from nvim-lspconfig)
local simple_servers = {
  'bashls',
  'clangd',
  'gdscript',
  'gopls',
  'jsonls',
  'lemminx',
  'marksman',
  'pyright',
  'rust_analyzer',
  'sourcekit',
  'ts_ls',
  'ocamllsp',
  'nixd',
  'jdtls',
}

for _, name in ipairs(simple_servers) do
  vim.lsp.enable(name)
end

-- 3. Servers you need to configure
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      formatters = { ignoreComments = true },
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { 'nixCats' },
        disable = { 'missing-fields' },
      },
      telemetry = { enabled = false },
    },
  },
})
vim.lsp.enable('lua_ls')

vim.lsp.config('ts_ls', {
  init_options = {
    hostInfo = 'neovim',
    tsserver = { path = nixCats('tsPath') },
  },
})
vim.lsp.enable('ts_ls')

vim.lsp.config('typos_lsp', {
  init_options = { diagnosticSeverity = 'Hint' },
})
vim.lsp.enable('typos_lsp')

vim.lsp.config('postgres_lsp', {
  cmd = { 'postgrestools', 'lsp-proxy' },
  filetypes = { 'sql' },
  root_markers = { 'postgrestools.jsonc', '.git' },
})
vim.lsp.enable('postgres_lsp')

-- 4. Metals: use nvim-metals plugin instead of lspconfig
-- (follow nvim-metals docs for 0.11+)

-- 5. Godot pipe (unchanged)
local pipepath = vim.fn.stdpath("cache") .. "/godot-server.pipe"
if not vim.loop.fs_stat(pipepath) then
  vim.fn.serverstart(pipepath)
end

require("myLuaConf.LSPs.dotnet").add_dotnet() -- c#
-- require("myLuaConf.LSPs.fss").add_fss(servers) -- fss
require('myLuaConf.LSPs.noneLs')
