-- Enforces a constant vertical gap between the status line and the cmdline
local config_fn = function(_, opts)
  require("noice").setup(opts)

  local NuiView = require("noice.view.nui")
  local get_layout = NuiView.get_layout

  local CMDLINE_GAP = 0 -- number of rows between status line and cmdline

  function NuiView:get_layout()
    local layout = get_layout(self)
    local position = (self._view_opts and self._view_opts.position) or self._opts.position
    if
      position
      and position.row == "bottom"
      and layout.size
      and type(layout.size.height) == "number"
    then
      local height = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win())
      layout.position.row = math.max(0, height - 1 - CMDLINE_GAP - layout.size.height)
    end
    return layout
  end
end

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
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
    cmdline = {
      view = "cmdline_popup",
      opts = {
        -- Anchor popups to the active window instead of the whole editor
        relative = { type = "win", winid = 0 },
        -- "bottom" is resolved in config() below so the distance to the
        -- statusline stays the same regardless of the window height.
        position = { row = "bottom", col = "50%" },
        size = { width = 60, height = "auto" },
        border = { style = "rounded" },
      },
    },
  },
  config = config_fn,
}
