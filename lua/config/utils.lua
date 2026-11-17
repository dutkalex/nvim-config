local current_directory = function()
  if vim.fn.bufname() == '' then
    return vim.uv.cwd()           -- No file open
  else
    return vim.fn.expand('%:p:h') -- Path of the currently opened file
  end
end

local normalize_dir = function(path)
  path = vim.fn.fnamemodify(path, ':p')
  if path ~= '/' then
    path = path:gsub('/$', '')
  end
  return path
end

local git_root_from = function(path)
  path = normalize_dir(path)
  while path ~= '/' and path ~= '' and path ~= '.' do
    if vim.fn.isdirectory(path .. '/.git') == 1 then -- ignores git submodules
      return path
    end
    path = vim.fn.fnamemodify(path, ':h')
  end
end

local find_git_root = function()
  return git_root_from(current_directory())
      or git_root_from(vim.uv.cwd())
      or normalize_dir(vim.uv.cwd())
end

local highlight_yanked_text = function()
  vim.highlight.on_yank({ higroup = 'Search' })
end

local if_not_oil = function(fn)
  return function()
    if vim.bo.filetype == "oil" then
      return
    end
    fn()
  end
end

local oil_parent_dir_key = function()
  if vim.loop.os_uname().sysname == "Darwin" then
    return "-"
  end
  return "="
end

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

local close_floating_windows = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_win_close(win, true)
    end
  end
end

return {
  current_directory = current_directory,
  find_git_root = find_git_root,
  highlight_yanked_text = highlight_yanked_text,
  if_not_oil = if_not_oil,
  oil_parent_dir_key = oil_parent_dir_key,
  format_selection = format_selection,
  close_floating_windows = close_floating_windows,
}
