local dap, dapui = require("dap"), require("dapui")

-- dap.set_log_level('DEBUG')

dap.adapters.coreclr = {
  type = 'executable',
  command = 'netcoredbg',
  args = { '--interpreter=vscode' },
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
  },
  {
    type = "coreclr",
    name = "attach - netcoredbg",
    request = "attach",
    processId = require('dap.utils').pick_process,
  },
}

-- doesn't work yet... TODO
-- require("easy-dotnet.netcoredbg").register_dap_variables_viewer()

dapui.setup()

-- > it will use the word under the cursor, or if in visual mode, the currently highlighted text.
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>di', dapui.eval, { noremap = true, silent = true, desc = '[D]ebug [I]nfo' })
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>dr",
  "<cmd>DapToggleRepl<CR>",
  { noremap = true, silent = true, desc = "[D]ebug [R]epl" })

vim.keymap.set(
  { "n", "v", "x" },
  "<leader>dc",
  "<cmd>DapContinue<CR>",
  { noremap = true, silent = true, desc = "[D]ebug [C]ontinue" })
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>ds",
  "<cmd>DapDisconnect<CR>",
  { noremap = true, silent = true, desc = "[D]ebug [S]top" })

vim.keymap.set(
  { "n", "v", "x" },
  "<leader>db",
  "<cmd>DapToggleBreakpoint<CR>",
  { noremap = true, silent = true, desc = "[D]ebug toggle [B]reakpoint" })
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>d0",
  "<cmd>DapClearBreakpoints<CR>",
  { noremap = true, silent = true, desc = "[D]ebug clear breakpoints" })

vim.keymap.set(
  { "n", "v", "x" },
  "<leader>d<Right>",
  "<cmd>DapStepOver<CR>",
  { noremap = true, silent = true, desc = "[D]ebug step over" })
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>d<Down>",
  "<cmd>DapStepInto<CR>",
  { noremap = true, silent = true, desc = "[D]ebug step into" })
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>d<Up>",
  "<cmd>DapStepOut<CR>",
  { noremap = true, silent = true, desc = "[D]ebug step out" })


-- add coloring? https://haseebmajid.dev/posts/2023-10-07-til-how-to-colour-dap-breakpointed-line-in-neovim/
local sign = vim.fn.sign_define

sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = ""})
sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = ""})
sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = ""})
sign('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })
