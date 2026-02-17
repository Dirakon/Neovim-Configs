-- Enable treesitter-based highlighting and folding for installed languages
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*', -- you can restrict this to specific filetypes if you want
  callback = function()
    pcall(vim.treesitter.start) -- safe to call even if no parser exists
  end,
})

-- Enable treesitter-based indentation (experimental)
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    pcall(function()
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end)
  end,
})



-- Swap keymaps
vim.keymap.set('n', ';l', function()
  require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
end, { desc = 'Swap with next parameter' })
vim.keymap.set('n', ';h', function()
  require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
end, { desc = 'Swap with previous parameter' })
