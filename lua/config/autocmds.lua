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

local highlight_trailing_spaces = function()
  vim.cmd([[match TrailingSpaces /\s\+$/]])
  vim.cmd.hi("TrailingSpaces ctermbg=red guibg=red")
end

local hide_trailing_spaces = function()
  vim.cmd.hi("clear TrailingSpaces")
end

vim.api.nvim_create_autocmd("BufEnter", { callback = highlight_trailing_spaces })
vim.api.nvim_create_autocmd("InsertEnter", { callback = hide_trailing_spaces })
vim.api.nvim_create_autocmd("InsertLeave", { callback = highlight_trailing_spaces })

vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*", callback = strip_diffs })
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank({ higroup = 'Search' }) end })
