local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " "..opts.title.." ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local create_mini_terminal = function()
  local new_term = create_floating_window({ title = "Mini Terminal" })
  if vim.bo[new_term.buf].buftype ~= "terminal" then
    vim.cmd.terminal()
    vim.cmd("startinsert")
  end
end

return {
  create_mini_terminal = create_mini_terminal,
}
