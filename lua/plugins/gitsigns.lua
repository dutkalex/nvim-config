return {
  "lewis6991/gitsigns.nvim",
  opts = {
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
      delay = 200,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> ',
    sign_priority = 6,
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

    local function set_diff_colors()
      local green = '#4EB151'
      local dark_green = '#2b612d'
      local very_dark_green = '#283a2a'
      -- local super_dark_green = '#1D2A1F'

      local red = '#BA4545'
      local dark_red = '#792d2d'
      local very_dark_red = '#4c2a2a'
      -- local super_dark_red = '#2E1919'

      -- Signs column
      vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = green })
      vim.api.nvim_set_hl(0, 'GitSignsStagedAdd', { fg = dark_green })
      vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = red })
      vim.api.nvim_set_hl(0, 'GitSignsStagedDelete', { fg = dark_red })
      vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'GitSignsAdd' })
      vim.api.nvim_set_hl(0, 'GitSignsStagedChange', { link = 'GitSignsStagedAdd' })

      -- Line numbers column
      vim.api.nvim_set_hl(0, 'GitSignsAddNr', { link = 'GitSignsAdd' })
      vim.api.nvim_set_hl(0, 'GitSignsStagedAddNr', { link = 'GitSignsStagedAdd' })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { link = 'GitSignsDelete' })
      vim.api.nvim_set_hl(0, 'GitSignsStagedDeleteNr', { link = 'GitSignsStagedDelete' })
      vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { link = 'GitSignsAddNr' })
      vim.api.nvim_set_hl(0, 'GitSignsStagedChangeNr', { link = 'GitSignsStagedAddNr' })

      -- Unified diffs
      vim.api.nvim_set_hl(0, 'GitSignsAddPreview', { bg = very_dark_green })
      vim.api.nvim_set_hl(0, 'GitSignsDeletePreview', { bg = very_dark_red })
      vim.api.nvim_set_hl(0, 'GitSignsChangePreview', { link = 'GitSignsAddPreview' })
      vim.api.nvim_set_hl(0, 'GitSignsAddInline', { bg = dark_green })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', { bg = dark_red })
      vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { link = 'GitSignsAddInline' })

      -- Side-by-side diffs
      vim.api.nvim_set_hl(0, 'DiffAdd', { bg = very_dark_green })
      vim.api.nvim_set_hl(0, 'DiffDelete', { fg = very_dark_red, bg = very_dark_red })
      vim.api.nvim_set_hl(0, 'DiffChange', { link = 'DiffAdd' })
      vim.api.nvim_set_hl(0, 'DiffText', { bg = dark_green })

      -- No line numbers on (virtual) deleted lines
      local linenr = vim.api.nvim_get_hl(0, { name = "LineNr", link = false })
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local bg = linenr.bg or normal.bg
      vim.api.nvim_set_hl(0, "GitSignsVirtLnum", { fg = bg, bg = bg })
    end

    set_diff_colors()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('GitSignsWordDiffColors', { clear = true }),
      callback = set_diff_colors,
    })

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
