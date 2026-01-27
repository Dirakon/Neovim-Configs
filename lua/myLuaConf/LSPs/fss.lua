-- TODO extract in utils or whatever
local function find_git_root(fname)
  -- Use the current buffer's path as the starting point for the git search
  local current_file = fname
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  local cwd = vim.fn.getcwd()

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

local function add_fss(servers)
  local fss_path = os.getenv("FSS_PATH")
  if fss_path ~= nil then
    require('fss').setup({ fss_bin = fss_path })
    vim.cmd([[autocmd BufRead,BufNewFile *.fss setfiletype fss]])
    -- SEE https://ryanisaacg.com/posts/nvim-lspconfig-custom-lsp
    require('lspconfig.configs').fss_ls = {
      default_config = {
        cmd = { fss_path, 'lsp' },
        filetypes = { 'fss' },
        root_dir = function(fname)
          -- print(fname)
          -- print(find_git_root(fname))
          return find_git_root(fname)
        end,
        settings = {},
      },
    }

    servers.fss_ls = {}
  else
    -- print("FSS_LS_PATH not set!")
  end
end


return
{
  add_fss = add_fss
}
