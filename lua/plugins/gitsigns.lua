return {
  "lewis6991/gitsigns.nvim",
  opts = {
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
    numhl      = true,
    -- linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    -- word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    -- watch_gitdir = {
    --   follow_files = true
    -- },
    -- auto_attach = true,
    -- attach_to_untracked = false,
    current_line_blame = true,
    current_line_blame_opts = {
      -- virt_text = true,
      virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
      delay = 200,
      -- ignore_whitespace = false,
      -- virt_text_priority = 100,
      -- use_focus = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> ',
    sign_priority = 6,
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
  },
  config = function(_, opts)
    require('gitsigns').setup(opts)

    local scope_blame_to_active_window = function()
      local win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        return -- Early exit on floating windows
      end

      if not vim.api.nvim__ns_set then
        return -- Early exit if the function is not available
      end

      local ns = vim.api.nvim_get_namespaces()['gitsigns_blame'] or vim.api.nvim_create_namespace('gitsigns_blame')
      vim.api.nvim__ns_set(ns, { wins = { win } })

      if require('gitsigns.config').config.current_line_blame then
        require('gitsigns.current_line_blame').update(vim.api.nvim_get_current_buf())
      end
    end

    local group = vim.api.nvim_create_augroup('GitSignsBlameScope', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'TabEnter' }, {
      group = group,
      callback = scope_blame_to_active_window,
    })
    vim.api.nvim_create_autocmd('WinClosed', {
      group = group,
      callback = function()
        vim.schedule(scope_blame_to_active_window)
      end,
    })

    scope_blame_to_active_window()
  end,
}
