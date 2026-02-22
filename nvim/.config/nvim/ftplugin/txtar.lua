if vim.b.txtar_ftplugin_loaded then
  return
end
vim.b.txtar_ftplugin_loaded = true

pcall(vim.treesitter.start, 0, 'txtar')
