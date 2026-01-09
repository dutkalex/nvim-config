return {
  'nvim-telescope/telescope.nvim', 
  tag = 'v0.2.1',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    require('telescope').setup {
      extensions = { fzf = {} }
    }
    require('telescope').load_extension('fzf')
  end
}
 
