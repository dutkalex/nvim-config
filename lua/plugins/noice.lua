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
      bottom_search = false,        -- use a classic bottom cmdline for search
      command_palette = true,       -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages sent to a split
      inc_rename = true,            -- incremental rename prompt
      lsp_doc_border = true,        -- add a border to hover docs and signature help
    },
  },
}
