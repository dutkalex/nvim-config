local jump_next_diagnostic = function()
  vim.diagnostic.jump({ count = 1, wrap = false })
end

local jump_prev_diagnostic = function()
  vim.diagnostic.jump({ count = -1, wrap = false })
end

local diagnostic_threshold = vim.diagnostic.severity.HINT

local function config_diagnostics(new_threshold)
  diagnostic_threshold = new_threshold

  vim.diagnostic.config({
    severity_sort = true,
    signs = { severity = { min = new_threshold } },
    virtual_text = { severity = { min = new_threshold } },
    underline = { severity = { min = vim.diagnostic.severity.HINT } },
  })
end

config_diagnostics(diagnostic_threshold)

local function more_diagnostics()
  if diagnostic_threshold == vim.diagnostic.severity.ERROR then
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

local function less_diagnostics()
  if diagnostic_threshold == vim.diagnostic.severity.HINT then
    config_diagnostics(vim.diagnostic.severity.INFO)
    vim.notify("Showing ERROR + WARN + INFO diagnostics", vim.log.levels.INFO)
  elseif diagnostic_threshold == vim.diagnostic.severity.INFO then
    config_diagnostics(vim.diagnostic.severity.WARN)
    vim.notify("Showing ERROR + WARN diagnostics", vim.log.levels.INFO)
  elseif diagnostic_threshold == vim.diagnostic.severity.WARN then
    config_diagnostics(vim.diagnostic.severity.ERROR)
    vim.notify("Showing ERROR diagnostics", vim.log.levels.INFO)
  else
    vim.notify("Already showing minimal diagnostics (ERROR only)", vim.log.levels.WARN)
  end
end

local show_diagnostic = function()
  vim.diagnostic.open_float({
    scope = "line",
    source = "if_many",
    border = "rounded",
  })

  vim.lsp.buf.code_action()
end

return {
  next = jump_next_diagnostic,
  prev = jump_prev_diagnostic,
  more = more_diagnostics,
  less = less_diagnostics,
  show = show_diagnostic,
}
