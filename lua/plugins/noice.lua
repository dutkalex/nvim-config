return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    lsp = {
      -- override markdown rendering so lsp signature and hover look better
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    -- keep frequent scroll/search messages out of the history
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "^After %d+%" },
            { find = "^Before %d+%" },
            { find = "%d fewer lines" },
            { find = "%d more lines" },
          },
        },
       opts = { skip = true },
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
    cmdline = {
      view = "cmdline_popup",
      opts = {
        position = { row = "97%", col = "50%" },
        size = { width = 60, height = "auto" },
        border = { style = "rounded" },
      },
    },
  },
}
