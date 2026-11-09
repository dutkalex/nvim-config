-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank({ higroup = 'Search' }) end })

-- Use command-mode color for the cmdline and search popups
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("noice_cmdline_border", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCmdline", { link = "DiagnosticSignWarn" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch",  { link = "DiagnosticSignWarn" })
    vim.api.nvim_set_hl(0, "NoiceCmdlineIconCmdline",        { link = "DiagnosticSignWarn" })
    vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch",         { link = "DiagnosticSignWarn" })
  end,
})
