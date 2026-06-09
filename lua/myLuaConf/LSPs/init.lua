vim.lsp.config('*', {
  capabilities = require('myLuaConf.LSPs.caps-on_attach').get_capabilities(),
  on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach,
})

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


local metals_config = require("metals").bare_config()
metals_config.settings = {
  -- useGlobalExecutable = true,
}
metals_config.on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})

local pipepath = vim.fn.stdpath("cache") .. "/godot-server.pipe"
if vim.loop.fs_stat("project.godot") then
  -- Delete existing pipe file if it exists
  if vim.loop.fs_stat(pipepath) then
    vim.fn.delete(pipepath)
  end
  vim.fn.serverstart(pipepath)
end

require("myLuaConf.LSPs.dotnet").add_dotnet() -- c#
-- require("myLuaConf.LSPs.fss").add_fss(servers) -- fss
require('myLuaConf.LSPs.noneLs')
