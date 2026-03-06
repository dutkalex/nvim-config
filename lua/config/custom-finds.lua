local telescope_builtin = require("telescope.builtin")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local utils = require("config.utils")

local open_in_new_tab = function(_, map)
  local fn = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.cmd("tabnew " .. selection.filename)
    if selection.lnum and selection.col then
      vim.api.nvim_win_set_cursor(0, {selection.lnum, selection.col})
    end
  end

  map('i', '<C-CR>', fn)
  map('n', '<C-CR>', fn)
  return true
end


local find_files = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or utils.find_git_root()
  opts.find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" }
  opts.attach_mappings = open_in_new_tab
  telescope_builtin.find_files(opts)
end

local find_neovim_config_files = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.fn.stdpath("config")
  -- opts.attach_mappings = open_in_new_tab
  telescope_builtin.find_files(opts)
end

local find_code = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or utils.find_git_root()
  opts.attach_mappings = open_in_new_tab

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
    prompt_title = "Find Code",
    finder = finder,
    previewer = conf.grep_previewer(opts),
    sorter = sorters.empty(),
  }):find()
end

local find_definitions = function(opts)
  opts = opts or {}
  opts.jump_type = "never"
  opts.attach_mappings = open_in_new_tab
  telescope_builtin.lsp_definitions(opts)
end

local find_references = function(opts)
  opts = opts or {}
  opts.jump_type = "never"
  opts.attach_mappings = open_in_new_tab
  telescope_builtin.lsp_references(opts)
end

return {
  find_files = find_files,
  find_neovim_config_files = find_neovim_config_files,
  find_code = find_code,
  find_definitions = find_definitions,
  find_references = find_references,
}
