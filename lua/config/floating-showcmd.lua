local M = {}

M.enable = function()
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
    -- Neovim renders a space as "<20>"; use a visible symbol instead.
    return (table.concat(parts):gsub("<20>", "␣"))
  end

  -- While a mapping is pending, state("m") is set. When Neovim discards an
  -- incomplete mapping it reuses those keys as a normal command, emitting a
  -- new showcmd (e.g. "f") with state("m") cleared. Track the previous event
  -- so that leftover update doesn't reopen the float.
  local was_mapping = false

  local handle_events = function(event, content)
    if event ~= "msg_showcmd" then
      return
    end

    local text = get_text(content)
    local from_mapping = vim.fn.state("m") ~= ""

    -- Clearing must not depend on the current mode: completing a keymap or
    -- discarding an incomplete one can change the mode before Neovim emits
    -- the empty event.
    if text == "" or ignore[text] then
      close()
      was_mapping = from_mapping
      return
    end

    if was_mapping and not from_mapping then
      -- Neovim is reinterpreting keys from a discarded mapping prefix.
      was_mapping = false
      close()
      return
    end

    was_mapping = from_mapping

    -- Only show pending commands in Normal mode.
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
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
end

return M
