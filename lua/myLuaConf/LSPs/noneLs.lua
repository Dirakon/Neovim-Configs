local null_ls = require('null-ls')

local enable_csharpier = nixCats('useCsharpierOverRoslynFormat')
local null_ls_sources = {
  null_ls.builtins.formatting.black,
  null_ls.builtins.formatting.nixfmt,
}
if enable_csharpier then
  table.insert(null_ls_sources, null_ls.builtins.formatting.csharpier)
end

null_ls.setup({
  sources = null_ls_sources,
})
