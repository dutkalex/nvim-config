return {
  'stevearc/oil.nvim',
  opts = {
    view_options = {
      show_hidden = true,
    },
    columns = {
      "permissions",
      "size",
      "mtime",
      "icon",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
}
