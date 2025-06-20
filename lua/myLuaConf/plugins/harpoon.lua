local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<C-i>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-i>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-i>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-i>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-i>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-i>4", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-i>b", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-i>n", function() harpoon:list():next() end)
