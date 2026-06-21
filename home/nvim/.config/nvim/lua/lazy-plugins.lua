-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  { import = 'plugins' },
}, {
  ui = {
    icons = {},
  },
})

-- vim: ts=2 sts=2 sw=2 et
