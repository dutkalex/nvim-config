local diagnostic_threshold = vim.diagnostic.severity.HINT

local config_diagnostics = function(new_threshold)
  diagnostic_threshold = new_threshold

  vim.diagnostic.config({
    severity_sort = true,
    signs = { severity = { min = new_threshold } },
    virtual_text = { severity = { min = new_threshold } },
    underline = { severity = { min = vim.diagnostic.severity.HINT } },
  })
end

config_diagnostics(diagnostic_threshold)

local M = {}

---@brief Display more diagnostics by lowering the severity threshold
---@note By default, all diagnostics (ERROR, WARN, INFO and HINT) are displayed
M.more_diagnostics = function()
  if vim.bo.filetype == "oil" then
    return
  end

  if not vim.diagnostic.is_enabled() then
    vim.diagnostic.enable(true)
    config_diagnostics(vim.diagnostic.severity.ERROR)
    vim.notify("Enabling diagnostics (ERROR only)")
  elseif diagnostic_threshold == vim.diagnostic.severity.ERROR then
    config_diagnostics(vim.diagnostic.severity.WARN)
    vim.notify("Showing ERROR + WARN diagnostics", vim.log.levels.INFO)
  elseif diagnostic_threshold == vim.diagnostic.severity.WARN then
    config_diagnostics(vim.diagnostic.severity.INFO)
    vim.notify("Showing ERROR + WARN + INFO diagnostics", vim.log.levels.INFO)
  elseif diagnostic_threshold == vim.diagnostic.severity.INFO then
    config_diagnostics(vim.diagnostic.severity.HINT)
    vim.notify("Showing ERROR + WARN + INFO + HINT diagnostics", vim.log.levels.INFO)
  else
    vim.notify("Already showing all diagnostics (ERROR + WARN + INFO + HINT)", vim.log.levels.WARN)
  end
end

---@brief Display less LSP diagnostics by increasing the severity threshold
---@note By default, all diagnostics (ERROR, WARN, INFO and HINT) are displayed
M.less_diagnostics = function()
  if vim.bo.filetype == "oil" then
    return
  end

  if diagnostic_threshold == vim.diagnostic.severity.HINT then
    config_diagnostics(vim.diagnostic.severity.INFO)
    vim.notify("Showing ERROR + WARN + INFO diagnostics", vim.log.levels.INFO)
  elseif diagnostic_threshold == vim.diagnostic.severity.INFO then
    config_diagnostics(vim.diagnostic.severity.WARN)
    vim.notify("Showing ERROR + WARN diagnostics", vim.log.levels.INFO)
  elseif diagnostic_threshold == vim.diagnostic.severity.WARN then
    config_diagnostics(vim.diagnostic.severity.ERROR)
    vim.notify("Showing ERROR diagnostics", vim.log.levels.INFO)
  elseif diagnostic_threshold == vim.diagnostic.severity.ERROR and vim.diagnostic.is_enabled() then
    vim.diagnostic.enable(false)
    vim.notify("Disabling diagnostics", vim.log.levels.INFO)
  else
    vim.notify("Diagnostics already disabled", vim.log.levels.WARN)
  end
end

---@brief Show details of the diagnostic under the cursor
M.show_diagnostic = function()
  if vim.bo.filetype == "oil" then
    return
  end

  vim.diagnostic.open_float({
    scope = "line",
    source = "if_many",
    border = "rounded",
  })

  vim.lsp.buf.code_action()
end

---@brief Jump the cursor to the next diagnostic
M.jump_next_diagnostic = function()
  if vim.bo.filetype == "oil" then
    return
  end

  vim.diagnostic.jump({ count = 1, wrap = false })
end

---@brief Jump the cursor to the previous diagnostic
M.jump_prev_diagnostic = function()
  if vim.bo.filetype == "oil" then
    return
  end

  vim.diagnostic.jump({ count = -1, wrap = false })
end

return M
