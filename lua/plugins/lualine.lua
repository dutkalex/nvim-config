return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      sections = {
        lualine_c = { -- Show full absolute paths
          {
            'filename',
            path = 2,
            shorting_target = 40,
            cond = function() return vim.bo.filetype ~= "oil" end
          },
          {
            function() return vim.fn.fnamemodify(require("oil").get_current_dir(), ":p") end,
            cond = function() return vim.bo.filetype == "oil" end,
          }
        }
      }
    })
  end
}
