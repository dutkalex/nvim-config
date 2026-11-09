local show = function()
  if vim.api.nvim_buf_get_name(0) ~= "" then
    vim.cmd([[match TrailingSpaces /\s\+$/]])
    vim.cmd.hi("TrailingSpaces ctermbg=red guibg=red")
  end
end

local hide = function()
  vim.cmd.hi("clear TrailingSpaces")
end

local auto_highlight = function()
  vim.api.nvim_create_autocmd("BufEnter",    { callback = show })
  vim.api.nvim_create_autocmd("InsertEnter", { callback = hide })
  vim.api.nvim_create_autocmd("InsertLeave", { callback = show })
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

local auto_strip_diffs = function()
  vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*", callback = strip_diffs })
end

return {
  auto_highlight = auto_highlight,
  auto_strip_diffs = auto_strip_diffs,
}
