require("neotest").setup({
  adapters = {
    require("neotest-dotnet")({
      dap = { justMyCode = false },
    }),
  },
})

vim.keymap.set('n', '<leader>Tr', (function() require("neotest").run.run() end), { desc = 'Neo[T]est - [R]un closest' })
vim.keymap.set('n', '<leader>TR', (function() require("neotest").run.run(vim.fn.expand("%")) end), { desc = 'Neo[T]est - [R]un all in file' })
vim.keymap.set('n', '<leader>Ts', (function() require("neotest").run.stop() end), { desc = 'Neo[T]est - [S]top' })
vim.keymap.set('n', '<leader>Td', (function() require("neotest").run.run({strategy = "dap"}) end), { desc = 'Neo[T]est - [D]ebug closest' })
vim.keymap.set('n', '<leader>Ts', (function() vim.cmd("Neotest summary") end), { desc = 'Neo[T]est - [S]ummary panel to right' })
vim.keymap.set('n', '<leader>TO', (function() vim.cmd("Neotest output-panel") end), { desc = 'Neo[T]est - [O]utput panel' })
vim.keymap.set('n', '<leader>To', (function() vim.cmd("Neotest output") end), { desc = 'Neo[T]est - [O]utput popup' })
