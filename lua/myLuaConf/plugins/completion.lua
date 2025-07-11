-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}
local lspkind = require('lspkind')

cmp.setup {
  formatting = {
    format = lspkind.cmp_format {
      mode = 'text',
      with_text = true,
      maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

      menu = {
        buffer = '[BUF]',
        nvim_lsp = '[LSP]',
        nvim_lsp_signature_help = '[LSP]',
        nvim_lsp_document_symbol = '[LSP]',
        nvim_lua = '[API]',
        path = '[PATH]',
        luasnip = '[SNIP]',
      },
    },
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping {
    ['<C-Space>'] = cmp.mapping.complete {},
    -- Original ctr-enter ('<C-CR>') does not work with tmux in alacrity... wtf... TODO:
    ['<C-y>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<CS-y>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<CS-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-n>'] = cmp.mapping(
      cmp.mapping.complete({
        config = {
          sources = cmp.config.sources({
            { name = 'cmp_ai' },
          }),
        },
      }),
      { 'i' }
    ),
  },

  sources = cmp.config.sources {
    -- The insertion order influences the priority of the sources
    { name = 'nvim_lsp' --[[ , keyword_length = 3 ]] },
    { name = 'nvim_lsp_signature_help' --[[ , keyword_length = 3  ]] },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
  enabled = function()
    return vim.bo[0].buftype ~= 'prompt'
  end,
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
}

cmp.setup.filetype('lua', {
  sources = cmp.config.sources {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' --[[ , keyword_length = 3  ]] },
    { name = 'nvim_lsp_signature_help' --[[ , keyword_length = 3  ]] },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
  {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' },
      },
    },
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'nvim_lsp_document_symbol' --[[ , keyword_length = 3  ]] },
    { name = 'buffer' },
    { name = 'cmdline_history' },
  },
  view = {
    entries = { name = 'wildmenu', separator = '|' },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources {
    { name = 'cmdline' },
    -- { name = 'cmdline_history' },
    { name = 'path' },
  },
})
