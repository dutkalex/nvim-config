local parsers = {
  "bash",
  "c",
  "cpp",
  "cmake",
  "doxygen",
  "lua",
  "markdown",
  "python",
  "rust",
  "toml",
  "yaml",
  "astro",
  "css",
  "javascript",
  "typescript"
}

local start_highlighting = function(ev)
  local bufnr = ev.buf
  local ft = vim.bo[ev.buf].filetype

  if ft == nil or ft == "" then
    return
  end

  local lang = vim.treesitter.language.get_lang(ft) or ft
  local ok, has_parser = pcall(vim.treesitter.language.add, lang)
  if not ok or not has_parser then
    return
  end

  if vim.treesitter.highlighter.active[bufnr] then
    return
  end

  pcall(vim.treesitter.start, bufnr, lang)
end

local enable = function()
  if vim.fn.executable("tree-sitter") ~= 1 then
    vim.notify("Treesitter CLI not available", vim.log.levels.INFO)
    return
  end
  require('nvim-treesitter').install(parsers)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_highlighting", { clear = true }),
    callback = start_highlighting,
  })
end

return {
  enable = enable,
}
