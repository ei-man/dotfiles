return {
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'enter',
      },
      appearance = {
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = { implementation = "rust" },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300
        },
      },
      signature = {
        enabled = true,
      }
    },
    opts_extend = { "sources.default" },
  }
}
