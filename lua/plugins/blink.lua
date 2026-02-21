return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',

  opts = {
    keymap = {
      preset = 'default',
      ['<Tab>'] = { 'select_and_accept', 'fallback' },
    },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = {
      menu = { auto_show = false },
      documentation = { auto_show = true },
      list = { selection = { auto_insert = false } },
    },
    sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },

  opts_extend = { "sources.default" }
}
