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
servers.nixd = {} -- nix (i think)
servers.nil_ls = {}  -- nix (i think)
servers.jdtls = {}  -- java
servers.jsonls = {}  -- json
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

servers.clangd = {} -- c(++)
servers.gdscript = {} -- godot, gdscript
local pipepath = vim.fn.stdpath("cache") .. "/godot-server.pipe"
if not vim.loop.fs_stat(pipepath) then
  vim.fn.serverstart(pipepath)
end


-- servers.gopls = {},
servers.pyright = {} -- python
servers.metals = {} -- scala
-- servers.rust_analyzer = {},
-- servers.tsserver = {},
-- servers.html = { filetypes = { 'html', 'twig', 'hbs'} },


-- if not require('nixCatsUtils').isNixCats and nixCats('lspDebugMode') then
--   vim.lsp.set_log_level("debug")
-- end
-- If you were to comment out this autocommand
-- and instead pass the on attach function directly to
-- nvim-lspconfig, it would do the same thing.
--vim.api.nvim_create_autocmd('LspAttach', {
--  group = vim.api.nvim_create_augroup('nixCats-lsp-attach', { clear = true }),
--  callback = function(event)
--    require('myLuaConf.LSPs.caps-on_attach').on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
--  end
--})


if nixCats('useVscodeLspOverOmnisharp') then
  -- roslyn does not use lspconfig yet - https://github.com/neovim/nvim-lspconfig/issues/2657
  -- based on https://github.com/tarantoj/kickstart-nix.nvim/blob/2317d2fee0d32cac352cf741089f26846ba9cb62/nvim/plugin/lsp.lua
  local capabilities2 =
      require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities2 = vim.tbl_deep_extend('force', capabilities2, {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = false,
      },
    },
  })

  require('roslyn').setup {
    exe = 'Microsoft.CodeAnalysis.LanguageServer',
    --  filewatching = false,
    config = {
      on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach,
      capabilities = capabilities2,
      settings = {
        ['csharp|completion'] = {
          ['dotnet_provide_regex_completions'] = true,
          ['dotnet_show_completion_items_from_unimported_namespaces'] = true,
          ['dotnet_show_name_completion_suggestions'] = true,
        },
        ['csharp|highlighting'] = {
          ['dotnet_highlight_related_json_components'] = true,
          ['dotnet_highlight_related_regex_components'] = true,
        },
        ['navigation'] = {
          ['dotnet_navigate_to_decompiled_sources'] = true,
        },
        ['csharp|inlay_hints'] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_indexer_parameters = true,
          dotnet_enable_inlay_hints_for_literal_parameters = true,
          dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          dotnet_enable_inlay_hints_for_other_parameters = true,
          dotnet_enable_inlay_hints_for_parameters = true,
          dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },
        ['csharp|code_lens'] = { dotnet_enable_tests_code_lens = false,
          dotnet_enable_references_code_lens = true
        },
        ['csharp|background_analysis'] = {
          dotnet_analyzer_diagnostics_scope = 'FullSolution',
          dotnet_compiler_diagnostics_scope = 'FullSolution',
        },
      },
    },
  }
else
  servers.omnisharp = { cmd = { 'OmniSharp' } }
end




-- if require('nixCatsUtils').isNixCats then
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
--else
--  require('mason').setup()
--  local mason_lspconfig = require 'mason-lspconfig'
--  mason_lspconfig.setup {
--    ensure_installed = vim.tbl_keys(servers),
--  }
--  mason_lspconfig.setup_handlers {
--    function(server_name)
--      require('lspconfig')[server_name].setup {
--        capabilities = require('myLuaConf.LSPs.caps-on_attach').get_capabilities(),
--        -- this line is interchangeable with the above LspAttach autocommand
--        -- on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach,
--        settings = servers[server_name],
--        filetypes = (servers[server_name] or {}).filetypes,
--      }
--    end,
--  }
--end
