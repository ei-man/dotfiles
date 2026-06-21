return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts_plugin = require('lazy.core.config').plugins['nvim-treesitter']
      if ts_plugin and ts_plugin.dir then
        local runtime_dir = ts_plugin.dir .. '/runtime'
        if vim.uv.fs_stat(runtime_dir) then
          vim.opt.rtp:append(runtime_dir)
        end
      end

      require('nvim-treesitter.parsers').txtar = {
        install_info = {
          path = vim.fn.stdpath('config') .. '/parser/txtar',
          generate = true,
          generate_from_json = false,
        },
        filetype = 'txtar',
        tier = 3,
      }

      vim.treesitter.language.register('txtar', 'txtar')

      if #vim.api.nvim_get_runtime_file('parser/txtar.*', false) > 0 then
        local ok, err = vim.treesitter.language.add('txtar')
        if not ok and err then
          vim.notify(('Failed to load txtar parser: %s'):format(err), vim.log.levels.WARN)
        end
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
