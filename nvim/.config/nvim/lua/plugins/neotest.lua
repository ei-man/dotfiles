return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-treesitter/nvim-treesitter',
    'fredrikaverpil/neotest-golang',
  },
  keys = {
    {
      '<leader>tr',
      function()
        require('neotest').run.run()
      end,
      desc = 'Test: Run nearest',
    },
    {
      '<leader>tf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Test: Run file',
    },
    {
      "<leader>ta",
      function()
        require('neotest').run.run(vim.loop.cwd())
      end,
      desc = 'Run all tests (project)',
    },
    {
      '<leader>tl',
      function()
        require('neotest').run.run_last()
      end,
      desc = 'Test: Run last',
    },
    {
      '<leader>to',
      function()
        require('neotest').output.open { enter = true }
      end,
      desc = 'Test: Show output',
    },
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Test: Toggle summary',
    },
    {
      '<leader>td',
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = 'Test: Debug nearest',
    },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require('neotest-golang') {
          go_test_args = { '-v', '-race', '-count=1', '-timeout=60s' },
        },
      },
    }
  end,
}
