return {
  'stevearc/oil.nvim',
  opts = {
    float = { border = "rounded" },
    confirmation = { border = "rounded" },
    progress = { border = "rounded" },
    ssh = { border = "rounded" },
    keymaps_help = { border = "rounded" },
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
