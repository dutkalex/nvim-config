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

local if_not_oil = function(fn)
  return function()
    if vim.bo.filetype == "oil" then
      return
    end
    fn()
  end
end

-- Find commands (leader f)
local telescope_builtin = require('telescope.builtin')
local custom_finds = require("config.custom-finds")
vim.keymap.set("n", "<leader>ff", custom_finds.find_files, { desc = "[F]ind [F]ile" })
vim.keymap.set("n", "<leader>frf", telescope_builtin.oldfiles, { desc = "[F]ind [R]ecent [F]ile" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "[F]ind [B]uffer" })
vim.keymap.set("n", "<leader>fnf", custom_finds.find_neovim_config_files, { desc = "[F]ind [N]eovim configuration [F]ile" })
vim.keymap.set("n", "<leader>fc", if_not_oil(custom_finds.find_code), { desc = "[F]ind [C]ode" })
vim.keymap.set("n", "<leader>fd", if_not_oil(custom_finds.find_definitions), { desc = "[F]ind [D]efinitions" })
vim.keymap.set("n", "<leader>fr", if_not_oil(custom_finds.find_references), { desc = "[F]ind [R]eferences" })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", telescope_builtin.keymaps, { desc = "[F]ind [K]eymap" })

-- Edit commands (leader e)
vim.keymap.set("n", "<leader>er", if_not_oil(vim.lsp.buf.rename), { desc = "[E]dit [R]ename" })
vim.keymap.set("n", "<leader>ef", if_not_oil(vim.lsp.buf.format), { desc = "[E]dit [F]ormat" })

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

vim.keymap.set("v", "<leader>ef", if_not_oil(format_selection), { desc = "[E]dit [F]ormat" })

-- Diagnostics commands (leader d)
local diag = require("config.diagnostics")
vim.keymap.set('n', '<leader>dd', if_not_oil(function() telescope_builtin.diagnostics({ bufnr = 0 }) end),
  { desc = "List [D]ocument [D]iagnostics" })
vim.keymap.set('n', '<leader>dn', if_not_oil(diag.next), { desc = "[D]iagnostic [N]ext" })
vim.keymap.set('n', '<leader>dp', if_not_oil(diag.prev), { desc = "[D]iagnostic [P]revious" })
vim.keymap.set("n", "<leader>dl", if_not_oil(diag.less), { desc = "[D]iagnostics show [L]ess" })
vim.keymap.set("n", "<leader>dm", if_not_oil(diag.more), { desc = "[D]iagnostics show [M]ore" })
vim.keymap.set("n", "<leader>ds", if_not_oil(diag.show), { desc = "[D]iagnostic [S]how" })

-- Git commands (leader g)
local git = require("config.git")
vim.keymap.set("n", "<leader>gn", if_not_oil(git.next_hunk), { desc = "[G]it [N]ext" })
vim.keymap.set("n", "<leader>gp", if_not_oil(git.prev_hunk), { desc = "[G]it [P]revious" })
vim.keymap.set("n", "<leader>gd", if_not_oil(git.preview_hunk_inline), { desc = "[G]it [D]iff" })
vim.keymap.set("n", "<leader>ga", if_not_oil(git.stage_hunk), { desc = "[G]it [A]dd" })
vim.keymap.set("n", "<leader>gr", if_not_oil(git.reset_hunk), { desc = "[G]it [R]eset" })
vim.keymap.set("n", "<leader>gb", if_not_oil(git.toggle_blame), { desc = "[G]it [B]lame" })

-- Terminal
local terminal = require("config.terminal")
vim.keymap.set("n", "<leader>mt", terminal.create_mini_terminal, { desc = "Open a new [M]ini [T]erminal" })
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>:q<CR>") -- double escape to close the mini terminal

local close_floating_windows = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_win_close(win, true)
    end
  end
end
vim.keymap.set("n", "<Esc>", close_floating_windows, { desc = "Close floating windows" })
