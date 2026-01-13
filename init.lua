require("config.lazy")

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
  virtual_lines = { current_line = true },
})

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

-- Colorscheme
vim.cmd.colorscheme("tokyonight")

-- Indentation line
local indentscope = require("mini.indentscope")

indentscope.setup({
  symbol = '|',
  animation = function(s, n) return 1 end,
})
vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Comment" })

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    -- local ok, node = pcall(vim.treesitter.get_node)
    -- if not ok then
    --   print("fail!")
    --   return
    -- end
    -- if not node then
    --   print("no node!")
    --   return
    --end
    -- if node:type() == "comment" then
    --   indentscope.undraw()
    --   vim.b.miniindentscope_disable = true
    -- else
    --   indentscope.draw()
    --   vim.b.miniindentscope_disable = false
    -- end
  end,
})

-- Status bar
require('lualine').setup()

-- Left bar
vim.opt.number = true -- line numbers
vim.opt.scrolloff = 8 -- keep at least 8 lines between the cursor and the top/bottom
vim.opt.signcolumn = "yes" -- always display sign column

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Keymaps
local keymaps = require("config.keymaps")
keymaps.enable_shift_selection()
keymaps.enable_alt_move_line()
keymaps.enable_telescope_keymaps()
keymaps.enable_diagnostics_keymaps()
keymaps.enable_gitsigns_keymaps()

-- Command line
-- noice = require('config.noice')
-- noice.setup()
-- local lualine_cmd_fg = vim.api.nvim_get_hl(0, { name = "LualineCommand" }).foreground
-- local lualine_cmd_bg = vim.api.nvim_get_hl(0, { name = "LualineCommand" }).background
--
-- vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = lualine_cmd_fg, bg = lualine_cmd_bg, bold = true })
-- vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = lualine_cmd_bg, bg = lualine_cmd_bg })
