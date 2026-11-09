local enable = function()
  if vim.fn.executable("tree-sitter") ~= 1 then
    vim.notify("Treesitter CLI not available", vim.log.levels.INFO)
    return
  end

  require('nvim-treesitter').install({
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
  })
end

return {
  enable = enable,
}
