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

vim.opt.number = true             -- line numbers
vim.opt.scrolloff = 8             -- keep at least 8 lines between the cursor and the top/bottom
vim.opt.signcolumn = "yes"        -- always display sign column
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.expandtab = true          -- insert spaces instead of tabs
vim.opt.inccommand = "split"      -- show find-replaces live
-- vim.opt.smartcase = true
-- vim.opt.ignorecase = true
vim.opt.splitbelow = true
vim.opt.splitright = true

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

-- Status bar
require('lualine').setup({
  sections = {
    lualine_c = { -- Show full absolute paths
      {
        'filename', path = 2, shorting_target = 40,
        cond = function() return vim.bo.filetype ~= "oil" end
      },
      {
        function() return vim.fn.fnamemodify(require("oil").get_current_dir(), ":p") end,
        cond = function() return vim.bo.filetype == "oil" end,
      }
    }
  }
})

-- Oil file navigation
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Find commands
local telescope_builtin = require('telescope.builtin')
local custom_finds = require("config.custom-finds")

local disable_if_oil_buffer = function(fn)
  return function()
    if vim.bo.filetype == "oil" then
      return
    end
    fn()
  end
end

vim.keymap.set("n", "ff", custom_finds.find_files, { desc = "[F]ind [F]ile" })
vim.keymap.set("n", "frf", telescope_builtin.oldfiles, { desc = "[F]ind [R]ecent [F]ile" })
vim.keymap.set("n", "fnf", custom_finds.find_neovim_config_files, { desc = "[F]ind [N]eovim configuration [F]ile" })
vim.keymap.set("n", "fc", disable_if_oil_buffer(custom_finds.find_code), { desc = "[F]ind [C]ode"})
vim.keymap.set("n", "fd", disable_if_oil_buffer(custom_finds.find_definitions), { desc = "[F]ind [D]efinitions" })
vim.keymap.set("n", "fr", disable_if_oil_buffer(custom_finds.find_references), { desc = "[F]ind [R]eferences" })
vim.keymap.set("n", "fh", disable_if_oil_buffer(telescope_builtin.help_tags), { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "fk", disable_if_oil_buffer(telescope_builtin.keymaps), { desc = "[F]ind [K]eymap" })

-- Terminal
local terminal = require("config.terminal")
vim.keymap.set("n", "mt", terminal.create_mini_terminal, { desc = "Open a new [M]ini [T]erminal" })
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>:q<CR>") -- double escape to close the mini terminal

-- Shift selection
vim.keymap.set("n", "<S-Up>",    "v<Up>",    { silent = true })
vim.keymap.set("n", "<S-Down>",  "v<Down>",  { silent = true })
vim.keymap.set("n", "<S-Left>",  "v<Left>",  { silent = true })
vim.keymap.set("n", "<S-Right>", "v<Right>", { silent = true })

vim.keymap.set("v", "<S-Up>",    "<Up>",    { silent = true })
vim.keymap.set("v", "<S-Down>",  "<Down>",  { silent = true })
vim.keymap.set("v", "<S-Left>",  "<Left>",  { silent = true })
vim.keymap.set("v", "<S-Right>", "<Right>", { silent = true })

vim.keymap.set("i", "<S-Up>",    "<Esc>v<Up>",    { silent = true })
vim.keymap.set("i", "<S-Down>",  "<Esc>v<Down>",  { silent = true })
vim.keymap.set("i", "<S-Left>",  "<Esc>v<Left>",  { silent = true })
vim.keymap.set("i", "<S-Right>", "<Esc>v<Right>", { silent = true })

-- Fast navigation with Alt+Arrows
vim.keymap.set("n", "<A-Up>", "{")
vim.keymap.set("n", "<A-Down>", "}")
vim.keymap.set("n", "<A-Left>", "^")
vim.keymap.set("n", "<A-Right>", "$")

-- Alt line moves
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv")

-- Tab indents
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

-- Diagnostics
local display_diagnostics = true
local toggle_diagnostics = function()
  display_diagnostics = not display_diagnostics
  vim.diagnostic.config({ virtual_lines = display_diagnostics })
end
toggle_diagnostics() -- disable by default, more robust this way

local jump_next_diagnostic = function()
  vim.diagnostic.jump({ count = 1, wrap = false })
end

local jump_prev_diagnostic = function()
  vim.diagnostic.jump({ count = -1, wrap = false })
end

vim.keymap.set('n', 'dn', disable_if_oil_buffer(jump_next_diagnostic), { desc = "[D]iagnostic [N]ext" })
vim.keymap.set('n', 'dp', disable_if_oil_buffer(jump_prev_diagnostic), { desc = "[D]iagnostic [P]revious" })
vim.keymap.set('n', 'ds', disable_if_oil_buffer(toggle_diagnostics), { desc = "[D]iagnostic [S]how" })
vim.keymap.set('n', 'dl', disable_if_oil_buffer(function() telescope_builtin.diagnostics({ bufnr = 0 }) end), { desc = "[D]iagnostics [L]ist" })
vim.keymap.set('n', 'df', disable_if_oil_buffer(vim.lsp.buf.code_action), { desc = '[D]iagnostic [F]ix'})

-- Git
local gitsigns = require('gitsigns')
vim.keymap.set("n", "gn", disable_if_oil_buffer(gitsigns.next_hunk), { desc = "[G]it [N]ext"})
vim.keymap.set("n", "gp", disable_if_oil_buffer(gitsigns.prev_hunk), { desc = "[G]it [P]revious"})
vim.keymap.set("n", "gd", disable_if_oil_buffer(gitsigns.preview_hunk_inline), { desc = "[G]it [D]iff" })
vim.keymap.set("n", "ga", disable_if_oil_buffer(gitsigns.stage_hunk), { desc = "[G]it [A]dd" })
vim.keymap.set("n", "gr", disable_if_oil_buffer(gitsigns.reset_hunk), { desc = "[G]it [R]eset" })

local strip_diffs = function()
  local start_line = vim.api.nvim_buf_get_mark(0, "[")[1]
  local end_line = vim.api.nvim_buf_get_mark(0, "]")[1]

  if start_line == 0 or end_line == 0 then
    return
  end

  local view = vim.fn.winsaveview()

  for i = start_line - 1, end_line - 1 do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
    local stripped = line:gsub("%s+$", "")
    if stripped ~= line then
      vim.api.nvim_buf_set_lines(0, i, i + 1, false, { stripped })
    end
  end

  vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*", callback = strip_diffs })

highlight_trailing_whitespaces = function()
  vim.cmd([[highlight ExtraWhitespace ctermbg=red guibg=red]])
  vim.cmd([[match ExtraWhitespace /\s\+$/]])
end
