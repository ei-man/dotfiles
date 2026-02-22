if vim.b.txtar_ftplugin_loaded then
  return
end
vim.b.txtar_ftplugin_loaded = true

require('txtar').attach(0)
