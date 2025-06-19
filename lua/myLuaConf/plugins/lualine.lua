require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'catppuccin',
    component_separators = '|',
    section_separators = '',
    globalstatus = true,
  },
  sections = {
    lualine_a = {
      -- 'mode'
    },
    lualine_b = {
      -- 'branch'
    },
    lualine_c = {
      -- {
      --   'filename', path = 1, status = true,
      -- },
    },
    lualine_x = {
      -- 'encoding', 'fileformat', 'filetype'
    },
    lualine_y = {
      -- 'progress'
    },
    lualine_z = {
      -- 'location'
    },
  },
  inactive_sections = {
  },
  tabline = {
    lualine_a = {
      -- 'buffers'
    },
    lualine_b = {
      'branch'
    },
    lualine_c = {
      {'filename', path = 1, status = true}, 'diagnostics'
    },
    lualine_x = {
      -- 'encoding', 'fileformat', 'filetype'
    },
    lualine_y = {
      -- 'progress'
    },
    lualine_z = {
      -- 'location'
    },
  },
})

-- Actually fully disable the unneeded bottom statusline
vim.opt.laststatus = 0
vim.o.stl = "%{repeat('-',winwidth('.'))}"
