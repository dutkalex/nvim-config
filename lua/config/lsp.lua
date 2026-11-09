local enable_lua = function()
  vim.lsp.config['lua_ls'] = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }
  vim.lsp.enable({'lua_ls'})
end

local enable_cpp = function()
  vim.lsp.config.clangd = {
    cmd = { 'clangd', '--background-index' },
    root_markers = { 'compile_commands.json', 'compile_flags.txt' },
    filetypes = { 'c', 'cpp' },
  }
  vim.lsp.enable({'clangd'})
end

local enable_python = function()
  vim.lsp.config.ruff = {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    settings = {},
  }
  vim.lsp.enable({'ruff'})

  vim.lsp.config.ty = {
    cmd = { 'ty', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ty.toml', '.git' },
  }
  vim.lsp.enable({'ty'})
end

local enable_all = function()
  enable_lua()
  enable_cpp()
  enable_python()
end

return {
  enable_all = enable_all,
  enable_lua = enable_lua,
  enable_cpp = enable_cpp,
  enable_python = enable_python,
}
