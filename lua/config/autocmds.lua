local show_trailing_spaces = function()
  if vim.api.nvim_buf_get_name(0) ~= "" then
    vim.cmd([[match TrailingSpaces /\s\+$/]])
    vim.cmd.hi("TrailingSpaces ctermbg=red guibg=red")
  end
end

local hide_trailing_spaces = function()
  vim.cmd.hi("clear TrailingSpaces")
end

local strip_diffs = function()
  local gs = require("gitsigns")
  if not gs then
    return
  end

  local hunks = gs.get_hunks()
  if not hunks then
    return
  end

  local view = vim.fn.winsaveview()

  -- Process lines in reverse so that line numbers remain valid
  for i_hunk = #hunks, 1, -1 do
    local start_line = hunks[i_hunk].added.start
    local count = hunks[i_hunk].added.count

    if count > 0 then
      for i = start_line + count - 1, start_line, -1 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if line then
          local stripped = line:gsub("%s+$", "")
          if stripped ~= line then
            vim.api.nvim_buf_set_lines(0, i - 1, i, false, { stripped })
          end
        end
      end
    end
  end

  vim.fn.winrestview(view)
end

-- Highlight trailing whitespaces, except in insert mode
vim.api.nvim_create_autocmd("BufEnter",    { callback = show_trailing_spaces })
vim.api.nvim_create_autocmd("InsertEnter", { callback = hide_trailing_spaces })
vim.api.nvim_create_autocmd("InsertLeave", { callback = show_trailing_spaces })

-- Remove trailing whitespaces on git diffs only
vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*", callback = strip_diffs })

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank({ higroup = 'Search' }) end })

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
