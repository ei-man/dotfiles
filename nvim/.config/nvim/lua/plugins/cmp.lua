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
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = { implementation = "rust" },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
            default_brackets = { '(', ')' },
            override_brackets_for_filetypes = {},
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
            },
          },
        },
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
