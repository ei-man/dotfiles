local function register_txtar_parser()
  local parser_path = vim.fs.joinpath(vim.fn.stdpath 'config', 'parsers', 'tree-sitter-txtar')
  local parser_config = require 'nvim-treesitter.parsers'
  parser_config.txtar = {
    install_info = {
      path = parser_path,
    },
    filetype = 'txtar',
    tier = 3,
  }
end

return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'go', 'starlark', 'python', 'txtar' },
      auto_install = true,
    },
    config = function(_, opts)
      local ts = require 'nvim-treesitter'
      ts.setup(opts)

      register_txtar_parser()
      local group = vim.api.nvim_create_augroup('txtar_treesitter_parser', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'TSUpdate',
        callback = register_txtar_parser,
      })

      if not pcall(vim.treesitter.language.add, 'txtar') then
        ts.install { 'txtar' }
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
