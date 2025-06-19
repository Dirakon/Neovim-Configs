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
servers.nixd = {} -- nix but better? https://github.com/helix-editor/helix/pull/10767
-- servers.nil_ls = {}  -- nix but worse? wtf?
servers.jdtls = {}  -- java
servers.jsonls = {}  -- json
servers.lemminx = {}  -- xml
servers.marksman = {}  -- markdown
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

servers.metals = {} -- scala
servers.clangd = {} -- c(++)
servers.gdscript = {} -- godot, gdscript
servers.sourcekit = {} -- swift

local pipepath = vim.fn.stdpath("cache") .. "/godot-server.pipe"
if not vim.loop.fs_stat(pipepath) then
  vim.fn.serverstart(pipepath)
end

servers.pyright = {} -- python
servers.rust_analyzer = {} -- rust
servers.postgres_lsp = {} -- pgsql

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
    --  filewatching = false,
    config = {
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


-- TODO extract in utils or whatever
local function find_git_root(fname)
  -- Use the current buffer's path as the starting point for the git search
  local current_file = fname
  local current_dir = vim.fn.fnamemodify(current_file, ":h")

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

local fss_ls_path = os.getenv("FSS_LS_PATH")
if fss_ls_path ~= nil then
  vim.cmd([[autocmd BufRead,BufNewFile *.fss setfiletype fss]])
  -- print("FSS_LS_PATH IS set!")
  -- SEE https://ryanisaacg.com/posts/nvim-lspconfig-custom-lsp
  require('lspconfig.configs').fss_ls = {
      default_config = {
          cmd = {fss_ls_path},
          filetypes = {'fss'};
          root_dir = function(fname)
              -- print(fname)
              -- print(find_git_root(fname))
              return find_git_root(fname)
          end;
          settings = {};
      };
  }

  servers.fss_ls = {}
else
  -- print("FSS_LS_PATH not set!")
end



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
