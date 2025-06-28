local servers = {}
servers.bashls = {
  cmd = {
    "bash-language-server",
    "start"
  },
  filetypes = { "sh", "zsh" }
}
servers.lua_ls = {
  Lua = {
    formatters = {
      ignoreComments = true,
    },
    signatureHelp = { enabled = true },
    diagnostics = {
      globals = { 'nixCats' },
      disable = { 'missing-fields' },
    },
  },
  telemetry = { enabled = false },
  filetypes = { 'lua' },
}
servers.nixd = {}     -- nix but better? https://github.com/helix-editor/helix/pull/10767
-- servers.nil_ls = {}  -- nix but worse? wtf?
servers.jdtls = {}    -- java
servers.jsonls = {}   -- json
servers.lemminx = {}  -- xml
servers.marksman = {} -- markdown
servers.typos_lsp = { -- all
  init_options = {
    diagnosticSeverity = "Hint"
  }
}
servers.ts_ls = { -- ts/js
  cmd = {
    "typescript-language-server",
    "--stdio"
  },
  init_options = {
    tsserver = {
      path = nixCats('tsPath')
    },
    hostInfo = "neovim",
  },
}

servers.metals = {}    -- scala
servers.clangd = {}    -- c(++)
servers.gdscript = {}  -- godot, gdscript
servers.sourcekit = {} -- swift

local pipepath = vim.fn.stdpath("cache") .. "/godot-server.pipe"
if not vim.loop.fs_stat(pipepath) then
  vim.fn.serverstart(pipepath)
end

servers.pyright = {}       -- python
servers.rust_analyzer = {} -- rust
servers.postgres_lsp = {}  -- pgsql

require("myLuaConf.LSPs.dotnet").add_dotnet(servers) -- c#
require("myLuaConf.LSPs.fss").add_fss(servers) -- fss

for server_name, _ in pairs(servers) do
  require('lspconfig')[server_name].setup({
    capabilities = require('myLuaConf.LSPs.caps-on_attach').get_capabilities(),
    -- this line is interchangeable with the above LspAttach autocommand
    on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach,
    settings = servers[server_name],
    filetypes = (servers[server_name] or {}).filetypes,
    cmd = (servers[server_name] or {}).cmd,
    init_options = (servers[server_name] or {}).init_options,
    root_pattern = (servers[server_name] or {}).root_pattern,
  })
end


require('myLuaConf.LSPs.noneLs')
