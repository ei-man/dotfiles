return {
  'Weissle/persistent-breakpoints.nvim',
  event = 'BufReadPost',
  config = function()
    require('persistent-breakpoints').setup {
      load_breakpoints_event = { 'BufReadPost' },
    }
  end,
  keys = {
    {
      '<leader>db',
      function()
        require('persistent-breakpoints.api').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('persistent-breakpoints.api').set_conditional_breakpoint()
      end,
      desc = 'Debug: Set Conditional Breakpoint',
    },
  },
}
