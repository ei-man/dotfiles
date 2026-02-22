-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 500

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.filetype.add {
  extension = {
    txtar = 'txtar',
  },
}

local function looks_like_txtar(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local max_lines = math.min(line_count, 200)
  if max_lines == 0 then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, max_lines, false)
  for _, line in ipairs(lines) do
    if line:match '^%-%-%s+.+%s+%-%-$' then
      return true
    end
  end

  return false
end

local txtar_detect_group = vim.api.nvim_create_augroup('txtar_detect', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  group = txtar_detect_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' then
      return
    end

    local name = vim.api.nvim_buf_get_name(args.buf)
    if name:match '%.txtar$' then
      vim.bo[args.buf].filetype = 'txtar'
      return
    end

    local ft = vim.bo[args.buf].filetype
    if ft ~= '' and ft ~= 'text' then
      return
    end

    if looks_like_txtar(args.buf) then
      vim.bo[args.buf].filetype = 'txtar'
    end
  end,
})

local txtar_group = vim.api.nvim_create_augroup('txtar_setup', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = txtar_group,
  pattern = 'txtar',
  callback = function(args)
    require('txtar').attach(args.buf)
  end,
})

-- vim: ts=2 sts=2 sw=2 et
