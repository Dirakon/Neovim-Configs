return
{
  add_dotnet = function(servers)
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

      require('roslyn').setup(
        {
          config = {
            -- )
            -- vim.lsp.config("roslyn", {
            cmd = {
              'Microsoft.CodeAnalysis.LanguageServer',
              "--logLevel=Information",
              "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
              "--stdio"
            },
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
              ['csharp|code_lens'] = {
                dotnet_enable_tests_code_lens = false,
                dotnet_enable_references_code_lens = true
              },
              ['csharp|background_analysis'] = {
                dotnet_analyzer_diagnostics_scope = 'FullSolution',
                dotnet_compiler_diagnostics_scope = 'FullSolution',
              },
            }
          }
        })
    else
      servers.omnisharp = { cmd = { 'OmniSharp' } }
    end
  end
}
