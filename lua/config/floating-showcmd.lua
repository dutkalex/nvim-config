local M = {}

local SUCCESS_DURATION = 200

M.enable = function()
  local buf = vim.api.nvim_create_buf(false, true)
  local group = vim.api.nvim_create_augroup("showcmd_float", { clear = true })
  local ns = vim.api.nvim_create_namespace("showcmd_float")
  local hl_ns = vim.api.nvim_create_namespace("showcmd_float_hl")
  local win
  local flash_timer
  local typed_fallback = ""
  local mapping_just_completed = ""
  local reinserting = false

  local function set_success_hl()
    vim.api.nvim_set_hl(0, "ShowcmdFloatSuccess", {
      fg = "#9ece6a",
      ctermfg = 10,
      bold = true,
    })
  end

  set_success_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = set_success_hl,
  })

  local function cancel_flash()
    if flash_timer then
      vim.fn.timer_stop(flash_timer)
      flash_timer = nil
    end
  end

  local function close()
    cancel_flash()
    typed_fallback = ""
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    win = nil
  end

  -- Entering the command line does not always clear showcmd (e.g. after a partial operator).
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
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

  local normalize = function(text)
    -- Neovim renders a space as "<20>" in showcmd and as "<Space>" via keytrans.
    return (text:gsub("<20>", "␣"):gsub("<Space>", "␣"))
  end

  local is_aborted = function(text)
    return text:find("\27", 1, true) ~= nil
      or text:find("^[", 1, true) ~= nil
      or text:find("<Esc>", 1, true) ~= nil
  end

  local get_text = function(content)
    local parts = {}
    for _, chunk in ipairs(content or {}) do
      parts[#parts + 1] = chunk[2]
    end
    return normalize(table.concat(parts))
  end

  local last_pending = ""
  local pending_at_clear = ""

  local function show(text, success)
    cancel_flash()
    if not success then
      last_pending = text
    end
    vim.api.nvim_buf_clear_namespace(buf, hl_ns, 0, -1)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })

    if success then
      vim.api.nvim_buf_add_highlight(buf, hl_ns, "ShowcmdFloatSuccess", 0, 0, -1)
    end

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

    if success then
      flash_timer = vim.fn.timer_start(SUCCESS_DURATION, function()
        flash_timer = nil
        close()
      end)
    end
  end

  -- While Neovim is waiting for a possible mapping prefix, state("m") is set.
  -- When it discards an incomplete mapping it reuses those keys as a normal
  -- command. Track that state so the leftover update doesn't reopen the float.
  local was_mapping = false

  local handle_events = function(event, content)
    if event ~= "msg_showcmd" then
      return
    end

    local text = get_text(content)
    local from_mapping = vim.fn.state("m") ~= ""

    -- A completed mapping can run commands that emit showcmd events of their
    -- own (e.g. gcc uses g@_). Keep showing the mapping's LHS until those
    -- events are done instead of replacing it with the internal command.
    if mapping_just_completed ~= "" then
      if text == "" then
        mapping_just_completed = ""
        typed_fallback = ""
      end
      return
    end

    -- A key re-injected after a timed-out mapping can run a command that emits
    -- its own showcmd (e.g. a mapped <Left> renders as "~@k"). Ignore those
    -- events; the abandoned prefix must not be flashed.
    if reinserting then
      if text == "" then
        reinserting = false
      end
      return
    end

    -- Clearing must not depend on the current mode: completing a command or
    -- discarding an incomplete one can change the mode before Neovim emits
    -- the empty event.
    if text == "" then
      if from_mapping then
        -- A mapping completion or discard. The completion callback supplies
        -- the full mapping; the incomplete prefix must not be flashed.
        pending_at_clear = last_pending
        last_pending = ""
        if pending_at_clear ~= "" then
          local cleared = pending_at_clear
          vim.defer_fn(function()
            if pending_at_clear == cleared then
              pending_at_clear = ""
            end
          end, 100)
        end
        was_mapping = true
        close()
        return
      end

      -- Built-in commands show their full sequence immediately before the
      -- clear event. If that update was coalesced away, fall back to the keys
      -- seen by on_key so fast commands still flash.
      local completed = last_pending
      if completed == "" then
        completed = normalize(typed_fallback)
      end
      last_pending = ""
      typed_fallback = ""
      pending_at_clear = ""
      was_mapping = false
      reinserting = false
      if completed ~= "" and not is_aborted(completed) then
        show(completed, true)
      else
        close()
      end
      return
    end

    if ignore[text] then
      last_pending = ""
      typed_fallback = ""
      pending_at_clear = ""
      was_mapping = from_mapping
      close()
      return
    end

    if was_mapping and not from_mapping then
      -- Neovim re-injects the keys of a discarded mapping prefix one at a
      -- time. Only suppress that immediate leftover update; a following
      -- command (e.g. the "gg" after a timed-out "g") is still real.
      local reinserted = vim.fn.strchars(text) == 1
        and pending_at_clear:find(text, 1, true) ~= nil
      was_mapping = false
      pending_at_clear = ""
      if reinserted then
        last_pending = ""
        typed_fallback = ""
        close()
        return
      end
    end

    was_mapping = from_mapping

    -- Only show pending commands in Normal mode.
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
      return
    end

    show(text, false)
  end

  -- When a mapping completes, on_key receives its whole LHS as `typed`, while
  -- discarded prefixes are re-injected one key at a time. Use that to show the
  -- completed keymap briefly in green and to re-enable normal showcmd updates.
  vim.on_key(function(_, typed)
    if typed == "" then
      return
    end

    local mode = vim.api.nvim_get_mode().mode
    local raw = vim.fn.keytrans(typed)
    local display = normalize(raw)

    -- Keys typed after leaving Normal-mode command state are not part of a
    -- showcmd sequence (e.g. text inserted after "i").
    if mode:sub(1, 1) ~= "n" then
      typed_fallback = ""
      return
    end

    -- Ignore keys consumed by an operator (e.g. the "f" in "df"); they are
    -- not completing a Normal-mode mapping even when "f" itself is mapped.
    if vim.fn.state():find("o", 1, true) == nil then
      local mapping = vim.fn.maparg(raw, "n", false, true)
      if type(mapping) == "table" and mapping.lhs then
        -- A discarded prefix can re-inject its last key (e.g. "\f" becomes
        -- "f"). Don't mistake that for a completed single-key mapping.
        if pending_at_clear ~= "" then
          if vim.fn.strchars(display) == 1 then
            local last = vim.fn.strcharpart(
              pending_at_clear,
              vim.fn.strchars(pending_at_clear) - 1,
              1
            )
            if last == display then
              typed_fallback = ""
              reinserting = true
              vim.defer_fn(function()
                if reinserting then
                  reinserting = false
                end
              end, 100)
              return
            end
          end
        end

        if is_aborted(display) then
          typed_fallback = ""
          return
        end

        was_mapping = false
        pending_at_clear = ""
        typed_fallback = ""
        reinserting = false
        mapping_just_completed = display
        vim.defer_fn(function()
          if mapping_just_completed == display then
            mapping_just_completed = ""
          end
        end, 100)
        show(display, true)
        return
      end
    end

    -- Remember keys even when Neovim coalesces the showcmd update away, so a
    -- fast built-in command can still be flashed when showcmd is cleared.
    local count = vim.fn.strchars(typed_fallback)
    if count > 32 then
      typed_fallback = vim.fn.strcharpart(typed_fallback, count - 32)
    end
    typed_fallback = typed_fallback .. display
  end, ns)

  vim.ui_attach(ns, { ext_messages = true }, handle_events)
end

return M
