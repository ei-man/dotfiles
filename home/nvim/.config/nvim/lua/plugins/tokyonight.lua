return {
  'marko-cerovac/material.nvim',
  priority = 1000,
  config = function()
    vim.g.material_style = 'deep ocean'
    require('material').setup()
    vim.cmd.colorscheme 'material'
  end,
}
-- vim: ts=2 sts=2 sw=2 et
