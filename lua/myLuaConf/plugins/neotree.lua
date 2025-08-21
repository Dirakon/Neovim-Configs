require("nvim-tree").setup({
	sync_root_with_cwd = true,
	respect_buf_cwd = true,
	git = {
		enable = true,
	},
	-- using the BufEnter thing below instead
	-- update_focused_file = {
	-- 	enable = true,
	-- 	update_root = false,
	-- },
	view = {
		width = 50,
	},
})

local api = require("nvim-tree.api")

-- https://github.com/nvim-tree/nvim-tree.lua/discussions/1929
local function collapse_and_find(data)
	if not api.tree.is_visible() then
	    return
	end

	-- don't collapse when entering nvim-tree
	if vim.bo[data.buf].buftype == "NvimTree" then
		return
	end

	api.tree.collapse_all()
	api.tree.find_file(data.file)
end

local function toggle_file_tree()
	api.tree.toggle()
	if api.tree.is_visible() then
		vim.cmd 'execute "normal! \\<C-w>l"'
	end
end

vim.keymap.set('n', '<leader>+', toggle_file_tree, { desc = 'Toggle file tree' })


-- auto close
local function is_modified_buffer_open(buffers)
	for _, v in pairs(buffers) do
		if v.name:match("NvimTree_") == nil then
			return true
		end
	end
	return false
end

vim.api.nvim_create_autocmd("BufEnter", {
	nested = true,
	callback = function(data)
		if
			#vim.api.nvim_list_wins() == 1
			and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil
			and is_modified_buffer_open(vim.fn.getbufinfo({ bufmodified = 1 })) == false
		then
			vim.cmd("quit")
		else
			collapse_and_find(data)
		end
	end,
})
