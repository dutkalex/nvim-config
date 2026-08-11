require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lsp")
require("config.lazy") -- Loads lua/plugins/*.lua files

-- Treesitter setup
require('nvim-treesitter').install({
  "bash",
  "c",
  "cpp",
  "cmake",
  "doxygen",
  "lua",
  "markdown",
  "python",
  "rust",
  "toml",
  "yaml",
  "astro",
  "css",
  "javascript",
  "typescript"
})


vim.cmd.colorscheme("tokyonight")
vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Comment" }) -- Color indentation line like comments

-- Oil file navigation
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>lz", "<cmd>Lazy<cr>", { desc = "Lazy" })

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

vim.keymap.set("n", "<leader>ff", custom_finds.find_files, { desc = "[F]ind [F]ile" })
vim.keymap.set("n", "<leader>frf", telescope_builtin.oldfiles, { desc = "[F]ind [R]ecent [F]ile" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "[F]ind [B]uffer" })
vim.keymap.set("n", "<leader>fnf", custom_finds.find_neovim_config_files, { desc = "[F]ind [N]eovim configuration [F]ile" })
vim.keymap.set("n", "<leader>fc", disable_if_oil_buffer(custom_finds.find_code), { desc = "[F]ind [C]ode" })
vim.keymap.set("n", "<leader>fd", disable_if_oil_buffer(custom_finds.find_definitions), { desc = "[F]ind [D]efinitions" })
vim.keymap.set("n", "<leader>fr", disable_if_oil_buffer(custom_finds.find_references), { desc = "[F]ind [R]eferences" })
vim.keymap.set("n", "<leader>fh", disable_if_oil_buffer(telescope_builtin.help_tags), { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", disable_if_oil_buffer(telescope_builtin.keymaps), { desc = "[F]ind [K]eymap" })

vim.keymap.set("n", "<leader>er", disable_if_oil_buffer(vim.lsp.buf.rename), { desc = "[E]dit [R]ename" })
vim.keymap.set("n", "<leader>ef", disable_if_oil_buffer(vim.lsp.buf.format), { desc = "[E]dit [F]ormat" })

local format_selection = function()
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")

  vim.lsp.buf.format({
    range = {
      ["start"] = { start_pos[1] - 1, start_pos[2] },
      ["end"] = { end_pos[1] - 1, end_pos[2] },
    },
  })
end

vim.keymap.set("v", "<leader>ef", disable_if_oil_buffer(format_selection), { desc = "[E]dit [F]ormat" })

-- Terminal
local terminal = require("config.terminal")
vim.keymap.set("n", "<leader>mt", terminal.create_mini_terminal, { desc = "Open a new [M]ini [T]erminal" })
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>:q<CR>") -- double escape to close the mini terminal


-- Diagnostics
local diag = require("config.diagnostics")
vim.keymap.set('n', '<leader>dd', disable_if_oil_buffer(function() telescope_builtin.diagnostics({ bufnr = 0 }) end),
  { desc = "List [D]ocument [D]iagnostics" })
vim.keymap.set('n', '<leader>dn', disable_if_oil_buffer(diag.next), { desc = "[D]iagnostic [N]ext" })
vim.keymap.set('n', '<leader>dp', disable_if_oil_buffer(diag.prev), { desc = "[D]iagnostic [P]revious" })
vim.keymap.set("n", "<leader>dl", disable_if_oil_buffer(diag.less), { desc = "[D]iagnostics show [L]ess" })
vim.keymap.set("n", "<leader>dm", disable_if_oil_buffer(diag.more), { desc = "[D]iagnostics show [M]ore" })
vim.keymap.set("n", "<leader>ds", disable_if_oil_buffer(diag.show), { desc = "[D]iagnostic [S]how" })

-- Git
local gitsigns = require('gitsigns')
vim.keymap.set("n", "<leader>gn", disable_if_oil_buffer(gitsigns.next_hunk), { desc = "[G]it [N]ext" })
vim.keymap.set("n", "<leader>gp", disable_if_oil_buffer(gitsigns.prev_hunk), { desc = "[G]it [P]revious" })
vim.keymap.set("n", "<leader>gd", disable_if_oil_buffer(gitsigns.preview_hunk_inline), { desc = "[G]it [D]iff" })
vim.keymap.set("n", "<leader>ga", disable_if_oil_buffer(gitsigns.stage_hunk), { desc = "[G]it [A]dd" })
vim.keymap.set("n", "<leader>gr", disable_if_oil_buffer(gitsigns.reset_hunk), { desc = "[G]it [R]eset" })


local close_floating_windows = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_win_close(win, true)
    end
  end
end
vim.keymap.set("n", "<Esc>", close_floating_windows, { desc = "Close floating windows" })
