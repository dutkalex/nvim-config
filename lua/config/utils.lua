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

local if_not_oil = function(fn)
  return function()
    if vim.bo.filetype == "oil" then
      return
    end
    fn()
  end
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

return {
    current_directory = current_directory,
    find_git_root = find_git_root,
    if_not_oil = if_not_oil,
    format_selection = format_selection,
}
