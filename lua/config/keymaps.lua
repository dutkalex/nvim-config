local utils = require("config.utils")

local shift_selection = function()
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
end

local alt_move_line = function()
  vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==")
  vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==")
  vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv")
  vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv")
end

local telescope_keymaps = function()
  local telescope = require("telescope")
  local fb_actions = telescope.extensions.file_browser.actions;
  telescope.setup({
    extensions = {
      file_browser = {
        theme = "ivy",
        hijack_netrw = true,
        grouped = true,
        mappings = {
          ["n"] = {
            ["<C-n>"] = fb_actions.create,
            ["<C-r>"] = fb_actions.rename,
            ["<C-d>"] = fb_actions.remove,
          },
          ["i"] = {
            ["<C-n>"] = fb_actions.create,
            ["<C-r>"] = fb_actions.rename,
            ["<C-d>"] = fb_actions.remove,
          }
        }
      },
    },
  })
  telescope.load_extension("file_browser")

  local telescope_themes = require("telescope.themes")
  local telescope_builtin = require('telescope.builtin')
  local custom_finds = require("config.custom-finds")

  local file_browser = function()
    local opts = {
      cwd = utils.current_directory()
    }
    telescope.extensions.file_browser.file_browser(opts)
  end
  vim.keymap.set("n", "fb", file_browser, { desc = "[F]ile [B]rowser" })

  local find_file = function()
    local opts = telescope_themes.get_ivy({})
    custom_finds.find_files(opts)
  end
  vim.keymap.set("n", "ff", find_file, { desc = "[F]ind [F]ile" })

  local find_code = function()
    local opts = telescope_themes.get_ivy({})
    custom_finds.find_code(opts)
  end
  vim.keymap.set("n", "fc", find_code, { desc = "[F]ind [C]ode"})

  vim.keymap.set("n", "fd", function() telescope_builtin.lsp_definitions({ jump_type = "never" }) end, { desc = "[F]ind [D]efinitions" })

  vim.keymap.set("n", "fr", function() telescope_builtin.lsp_references({ jump_type = "never" }) end, { desc = "[F]ind [R]eferences" })

  local find_neovim = function()
    local opts = { cwd = vim.fn.stdpath("config") }
    telescope_builtin.find_files(opts)
  end
  vim.keymap.set("n", "fn", find_neovim, { desc = "[F]ind [N]eovim configuration file" })

  local find_help = function()
    local opts = telescope_themes.get_ivy({})
    telescope_builtin.help_tags(opts)
  end
  vim.keymap.set("n", "fh", find_help, { desc = "[F]ind [H]elp" })

  local find_keymap = function()
    telescope_builtin.keymaps()
  end
  vim.keymap.set("n", "fk", find_keymap, { desc = "[F]ind [K]eymap" })
end

local display_diagnostics = true
local toggle_diagnostics = function()
  display_diagnostics = not display_diagnostics
  vim.diagnostic.config({ virtual_lines = display_diagnostics })
end

local diagnostics_keymaps = function()
  local telescope_builtin = require('telescope.builtin')
  vim.keymap.set('n', 'dl', function() telescope_builtin.diagnostics({ bufnr = 0 }) end, { desc = "[D]iagnostics [L]ist" })
  vim.keymap.set('n', 'de', vim.diagnostic.open_float, { desc = '[D]iagnostic [E]xtend' })
  vim.keymap.set('n', 'df', vim.lsp.buf.code_action, { desc = '[D]iagnostic [F]ix'})
  vim.keymap.set('n', 'ds', toggle_diagnostics, { desc = "[D]iagnostic [S]how" })
  toggle_diagnostics() -- off by default
end

local gitsigns_keymaps = function()
  local gitsigns = require('gitsigns')

  gitsigns.setup({
    -- signs = {
    --   add          = { text = '┃' },
    --   change       = { text = '┃' },
    --   delete       = { text = '_' },
    --   topdelete    = { text = '‾' },
    --   changedelete = { text = '~' },
    --   untracked    = { text = '┆' },
    -- },
    -- signs_staged = {
    --   add          = { text = '┃' },
    --   change       = { text = '┃' },
    --   delete       = { text = '_' },
    --   topdelete    = { text = '‾' },
    --   changedelete = { text = '~' },
    --   untracked    = { text = '┆' },
    -- },
    -- signs_staged_enable = true,
    -- signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    -- numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    -- linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    -- word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    -- watch_gitdir = {
    --   follow_files = true
    -- },
    -- auto_attach = true,
    -- attach_to_untracked = false,
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      -- virt_text = true,
      virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
      delay = 200,
      -- ignore_whitespace = false,
      -- virt_text_priority = 100,
      -- use_focus = true,
    },
    -- current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    -- sign_priority = 6,
    -- update_debounce = 100,
    -- status_formatter = nil, -- Use default
    -- max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = { -- Options passed to nvim_open_win
      border = 'rounded',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1
    },
  })
  gitsigns.toggle_current_line_blame() -- disable by default

  vim.keymap.set("n", "gd", gitsigns.preview_hunk_inline)

  -- vim.keymap.set("n", "ga", gitsigns.stage_hunk)

  -- vim.keymap.set("n", "gr", gitsigns.reset_hunk)

  -- vim.keymap.set("n", "gwd", "<cmd>Gitsigns toggle_word_diff<CR>")

  vim.keymap.set("n", "gbl", "<cmd>Gitsigns toggle_current_line_blame<CR>")
end

return {
  enable_shift_selection = shift_selection,
  enable_alt_move_line = alt_move_line,
  enable_telescope_keymaps = telescope_keymaps,
  enable_diagnostics_keymaps = diagnostics_keymaps,
  enable_gitsigns_keymaps = gitsigns_keymaps,
}
