-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  checker = { enabled = true },
})

-- Treesitter setup
require('nvim-treesitter').install({
  "lua",
  "python",
  "c",
  "cpp",
  "cmake",
  "markdown",
  "yaml",
  "toml",
  "bash",
})

-- LSP setup
vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      -- diagnostics = {
      --   globals = { 'vim' },
      -- },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
vim.lsp.enable({'lua_ls'})

vim.lsp.config.clangd = {
  cmd = { 'clangd', '--background-index' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt' },
  filetypes = { 'c', 'cpp' },
}
vim.lsp.enable({'clangd'})

vim.diagnostic.config({
  virtual_text = { current_line = true },
})

-- Colorscheme
vim.cmd [[colorscheme tokyonight]]

-- Line numbers
vim.opt.number = true

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Keymaps
local keymaps = require("config.keymaps")
keymaps.enable_shift_selection()
keymaps.enable_telescope_keymaps()
keymaps.enable_gitsigns_keymaps()

vim.keymap.set('n', 'ed', vim.diagnostic.open_float)
vim.keymap.set('n', 'df', vim.lsp.buf.code_action)