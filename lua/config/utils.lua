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

return {
    current_directory = current_directory,
    find_git_root = find_git_root,
}