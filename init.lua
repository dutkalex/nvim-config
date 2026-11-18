require("config.lazy")            -- Loads lua/plugins/*.lua files

vim.opt.number = true             -- show line numbers
vim.opt.scrolloff = 12            -- padding between cursor and top/bottom
vim.opt.signcolumn = "yes"        -- always display sign column
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.expandtab = true          -- insert spaces instead of tabs
vim.opt.splitbelow = true         -- open horizontal split on the bottom
vim.opt.splitright = true         -- open vertical split on the right
vim.opt.cursorline = true         -- highlight current line
vim.opt.inccommand = "split"      -- show find-replaces live
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

local lsp = require("config.lsp")
lsp.enable_all()

local treesitter = require("config.treesitter")
treesitter.enable()

local showcmd = require("config.floating-showcmd")
showcmd.enable()

local trailing_spaces = require("config.trailing-spaces")
trailing_spaces.auto_highlight()
trailing_spaces.auto_strip_diffs()

local utils = require("config.utils")
vim.api.nvim_create_autocmd("TextYankPost", { callback = utils.highlight_yanked_text })

-- Use command-mode color for the cmdline and search popups
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("noice_cmdline_border", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCmdline", { link = "DiagnosticSignWarn" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch",  { link = "DiagnosticSignWarn" })
    vim.api.nvim_set_hl(0, "NoiceCmdlineIconCmdline",        { link = "DiagnosticSignWarn" })
    vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch",         { link = "DiagnosticSignWarn" })
  end,
})

vim.cmd.colorscheme("tokyonight")


vim.keymap.set("n", "<leader>lz", "<cmd>Lazy<cr>", { desc = "Lazy" })

vim.keymap.set("n", "<leader>nh", "<cmd>Noice history<cr>", { desc = "[N]otification [H]istory" })

-- Navigate faster with Alt
vim.keymap.set("n", "<A-Up>",   "10k", { silent = true })
vim.keymap.set("n", "<A-Down>", "10j", { silent = true })

-- Select with Shift
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

-- Move selection with Alt
vim.keymap.set("v", "<A-Up>",     ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-Down>",   ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("n", "<S-A-Up>",   ":m-2<CR>",         { silent = true })
vim.keymap.set("n", "<S-A-Down>", ":m+1<CR>",         { silent = true })

-- Indent selection with Tab
vim.keymap.set("v", "<Tab>",   ">gv", { silent = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { silent = true })

-- Jump to the last buffer
vim.keymap.set("n", "<BS>", "<cmd>b#<CR>", { silent = true, desc = "Last buffer" })

-- Oil file navigation
vim.keymap.set("n", utils.oil_parent_dir_key(), "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Find commands (leader f)
local telescope_builtin = require('telescope.builtin')
local custom_finds = require("config.custom-finds")

vim.keymap.set("n", "<leader>ff", custom_finds.find_files, { desc = "[F]ind [F]ile" })
vim.keymap.set("n", "<leader>fc", custom_finds.find_code, { desc = "[F]ind [C]ode" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "[F]ind [B]uffer" })
vim.keymap.set("n", "<leader>fd", custom_finds.find_definitions, { desc = "[F]ind [D]efinitions" })
vim.keymap.set("n", "<leader>fr", custom_finds.find_references, { desc = "[F]ind [R]eferences" })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", telescope_builtin.keymaps, { desc = "[F]ind [K]eymap" })

-- Edit commands (leader e)
vim.keymap.set("n", "<leader>er", utils.if_not_oil(vim.lsp.buf.rename), { desc = "[E]dit [R]ename" })
vim.keymap.set("n", "<leader>ef", utils.if_not_oil(vim.lsp.buf.format), { desc = "[E]dit [F]ormat" })
vim.keymap.set("v", "<leader>ef", utils.if_not_oil(utils.format_selection), { desc = "[E]dit [F]ormat" })

-- Diagnostics commands (leader d)
local diag = require("config.diagnostics")
vim.keymap.set('n', '<leader>dn', diag.jump_next, { desc = "[D]iagnostic [N]ext" })
vim.keymap.set('n', '<leader>dp', diag.jump_prev, { desc = "[D]iagnostic [P]revious" })
vim.keymap.set("n", "<leader>dl", diag.display_less, { desc = "[D]iagnostics display [L]ess" })
vim.keymap.set("n", "<leader>dm", diag.display_more, { desc = "[D]iagnostics display [M]ore" })
vim.keymap.set("n", "<leader>ds", diag.show_details, { desc = "[D]iagnostic [S]how details" })

-- Git commands (leader g)
local git = require("config.git")
vim.keymap.set("n", "<leader>gn", git.next_hunk, { desc = "[G]it [N]ext hunk" })
vim.keymap.set("n", "<leader>gp", git.prev_hunk, { desc = "[G]it [P]revious hunk" })
vim.keymap.set("n", "<leader>gd", git.preview_hunk_inline, { desc = "[G]it [D]iff current hunk" })
vim.keymap.set("n", "<leader>ga", git.stage_hunk, { desc = "[G]it [A]dd current hunk" })
vim.keymap.set("n", "<leader>gr", git.reset_hunk, { desc = "[G]it [R]eset current hunk" })
vim.keymap.set("n", "<leader>gD", git.preview_buffer_hunks_inline, { desc = "[G]it [D]iff all buffer hunks" })
vim.keymap.set("n", "<leader>gA", git.stage_buffer_hunks, { desc = "[G]it [A]dd all buffer hunks" })
vim.keymap.set("n", "<leader>gR", git.reset_buffer_hunks, { desc = "[G]it [R]eset all buffer hunks" })

-- Terminal
local terminal = require("config.terminal")
vim.keymap.set("n", "<leader>mt", terminal.create_mini_terminal, { desc = "Open a new [M]ini [T]erminal" })
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>:q<CR>") -- double escape to close the mini terminal

vim.keymap.set("n", "<Esc>", utils.close_floating_windows, { desc = "Close floating windows" })
