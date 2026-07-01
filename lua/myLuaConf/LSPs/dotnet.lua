local function calculateServerPath()
    local net9RoslynPath = nixCats('net9RoslynPath')
    local net10RoslynPath = nixCats('net10RoslynPath')

    -- Based on environment variable:
    if os.getenv("USE_NET10_ROSLYN") then
       return net10RoslynPath
    else
        return net9RoslynPath
    end
end

return
{
  add_dotnet = function()
      vim.lsp.config("roslyn", {
          cmd = {
              calculateServerPath(),
              "--stdio",
          },
          settings = {
              ["csharp|inlay_hints"] = {
                  csharp_enable_inlay_hints_for_implicit_object_creation = true,
                  csharp_enable_inlay_hints_for_implicit_variable_types = true,
              },
              ["csharp|code_lens"] = {
                  dotnet_enable_references_code_lens = true,
              },
          },
      })

      vim.lsp.enable("roslyn")
    -- F# is also here!
    -- wait, it's already enabled by default in vimPlugins.Ionide-vim? 
  end
}
