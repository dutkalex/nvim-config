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

vim.keymap.set('n', 'ed', vim.diagnostic.open_float)
vim.keymap.set('n', 'df', vim.lsp.buf.code_action)

-- Gitsigns
require('gitsigns').setup {
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
}

local gitsigns = require('gitsigns')
vim.keymap.set("n", "gd", gitsigns.preview_hunk_inline)
-- vim.keymap.set("n", "ga", gitsigns.stage_hunk)
-- vim.keymap.set("n", "gr", gitsigns.reset_hunk)
-- vim.keymap.set("n", "gwd", "<cmd>Gitsigns toggle_word_diff<CR>")
vim.keymap.set("n", "gbl", "<cmd>Gitsigns toggle_current_line_blame<CR>")
gitsigns.toggle_current_line_blame() -- disable by default

-- Telescope setup
local fb_actions = require 'telescope'.extensions.file_browser.actions;

require("telescope").setup {
  extensions = {
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
      grouped = true,
      mappings = {
        ["n"] = {
          ["<C-n>"] = fb_actions.create,
        },
        ["i"] = {
          ["<C-n>"] = fb_actions.create,
        }
      }
    },
  },
}

local current_directory = function()
  if vim.fn.bufname() == '' then
    return vim.uv.cwd()  -- No file open
  else
    return vim.fn.expand('%:p:h') -- Path of the currently opened file
  end
end

local find_git_root = function()
  local path = current_directory()
  while path ~= '/' do
    if vim.fn.isdirectory(path .. '/.git') == 1 then -- ignores git submodules
      return path
    end
    path = vim.fn.fnamemodify(path, ':h')
  end
  return nil
end

require("telescope").load_extension("file_browser")
vim.keymap.set("n", "fb", function()
    local opts = {
        cwd = current_directory()
    }
	require("telescope").extensions.file_browser.file_browser(opts)
end)

vim.keymap.set("n", "ff", function()
  local opts = require('telescope.themes').get_ivy({})
  opts.cwd = find_git_root()
  require('telescope.builtin').find_files(opts)
end)

-- local telescope = require('telescope')
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
-- local actions = require('telescope.actions')
-- local action_state = require('telescope.actions.state')

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or find_git_root()

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end

      ---@diagnostic disable-next-line: deprecated
      return vim.tbl_flatten {
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers.new(opts, {
    debounce = 100,
    prompt_title = "Multi Grep",
    finder = finder,
    previewer = conf.grep_previewer(opts),
    sorter = require("telescope.sorters").empty(),
  }):find()
end
vim.keymap.set("n", "fc", function()
  local opts = require('telescope.themes').get_ivy({})
  live_multigrep(opts)
end)

vim.keymap.set("n", "fd", require('telescope.builtin').lsp_definitions, { desc = "[F]ind [D]efinitions" })
vim.keymap.set("n", "fr", require('telescope.builtin').lsp_references, { desc = "[F]ind [R]eferences" })

-- vim.keymap.set("n", "conf", function()
--   local opts = { cwd = vim.fn.stdpath("config") }
--   require('telescope.builtin').find_files(opts)
-- end)

-- vim.keymap.set("n", "help", function()
--   local opts = require('telescope.themes').get_ivy({})
--   require('telescope.builtin').help_tags(opts)
-- end)

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


-- Shift-based text selection
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

-- vim.keymap.set("v", "tc", "gcgv", { silent = false })
