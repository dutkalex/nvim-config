-- Floating 'showcmd': shows the pending (incomplete) key sequence in the bottom-right corner.
local buf = vim.api.nvim_create_buf(false, true)
local win

local function close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
end

-- Entering the command line does not always clear showcmd (e.g. after a partial operator).
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = vim.api.nvim_create_augroup("showcmd_float", { clear = true }),
  callback = close,
})

-- These are showcmd while still in normal mode, but they start a command line or Visual mode.
local ignore = {
  [":"] = true,
  ["/"] = true,
  ["?"] = true,
  ["="] = true,
  ["@"] = true,
  ["-"] = true,
  ["v"] = true,
  ["V"] = true,
  ["^V"] = true,
}

local get_text = function(content)
  local parts = {}
  for _, chunk in ipairs(content or {}) do
    parts[#parts + 1] = chunk[2]
  end
  return table.concat(parts)
end

local handle_events = function(event, content)
  if event ~= "msg_showcmd" or vim.api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
    return
  end

  local text = get_text(content)

  if text == "" or ignore[text] then
    close()
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })

  local opts = {
    relative = "editor",
    anchor = "SE",
    row = vim.o.lines - 1,
    col = vim.o.columns - 2,
    width = math.max(1, vim.api.nvim_strwidth(text)),
    height = 1,
    style = "minimal",
    border = "rounded",
    focusable = false,
  }

  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_config(win, opts)
  else
    win = vim.api.nvim_open_win(buf, false, opts)
    -- Use the colorscheme background for both the float body and its border.
    local border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
    border.bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
    vim.api.nvim_set_hl(0, "ShowcmdFloatBorder", border)
    vim.wo[win].winhl = "NormalFloat:Normal,FloatBorder:ShowcmdFloatBorder"
  end

  -- A new float opened from a UI event is not painted until the next redraw.
  vim.api.nvim__redraw({ flush = true })
end

local ns = vim.api.nvim_create_namespace("showcmd_float")
vim.ui_attach(ns, { ext_messages = true }, handle_events)
