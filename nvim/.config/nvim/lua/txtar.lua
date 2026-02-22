local M = {}

local function syntax_cmd(bufnr, cmd)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd(cmd)
  end)
end

local function escape_vim_pattern(text)
  return vim.fn.escape(text, '\\/.*$^~[]')
end

local function collect_archived_filenames(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local seen = {}
  local filenames = {}

  for _, line in ipairs(lines) do
    local filename = line:match '^%-%-%s+(.+)%s+%-%-$'
    if filename and not seen[filename] then
      seen[filename] = true
      table.insert(filenames, filename)
    end
  end

  return filenames
end

local function ensure_syntax_enabled(bufnr)
  local current = vim.bo[bufnr].syntax
  if current == '' or current == 'off' then
    vim.bo[bufnr].syntax = 'ON'
  end
end

local function define_base_syntax(bufnr)
  local base_groups = {
    'txtarComment',
    'txtarInlineComment',
    'txtarArchiveFilename',
    'txtarArchiveDash',
    'txtarArchiveRef',
    'txtarBangCommand',
    'txtarCommand',
  }
  for _, group in ipairs(base_groups) do
    syntax_cmd(bufnr, ('silent! syntax clear %s'):format(group))
  end

  syntax_cmd(bufnr, [[syntax match txtarComment /^\s*#.*$/]])
  syntax_cmd(bufnr, [[syntax match txtarInlineComment /\s#.*$/]])
  syntax_cmd(bufnr, [[syntax match txtarArchiveFilename /^--\s\+\zs\S\+\ze\s\+--$/]])
  syntax_cmd(bufnr, [[syntax match txtarArchiveDash /^--\|\s\+--$/]])
  syntax_cmd(bufnr, [[syntax match txtarArchiveRef /@\S\+/]])
  syntax_cmd(bufnr, [[syntax match txtarBangCommand /^!\s\+/]])
  syntax_cmd(bufnr, [[syntax keyword txtarCommand run write-file assert-file]])

  syntax_cmd(bufnr, [[highlight default link txtarComment Comment]])
  syntax_cmd(bufnr, [[highlight default link txtarInlineComment Comment]])
  syntax_cmd(bufnr, [[highlight default link txtarArchiveFilename Title]])
  syntax_cmd(bufnr, [[highlight default link txtarArchiveDash Delimiter]])
  syntax_cmd(bufnr, [[highlight default link txtarArchiveRef Identifier]])
  syntax_cmd(bufnr, [[highlight default link txtarBangCommand Operator]])
  syntax_cmd(bufnr, [[highlight default link txtarCommand Keyword]])
end

function M.apply(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].filetype ~= 'txtar' then
    return
  end

  ensure_syntax_enabled(bufnr)
  define_base_syntax(bufnr)

  local filenames = collect_archived_filenames(bufnr)

  local previous_groups = vim.b[bufnr].txtar_dynamic_groups or {}
  for _, group in ipairs(previous_groups) do
    syntax_cmd(bufnr, ('silent! syntax clear %s'):format(group))
  end

  local included_fts = vim.b[bufnr].txtar_included_fts or {}
  local dynamic_groups = {}
  local index = 0

  for _, filename in ipairs(filenames) do
    local filetype = vim.filetype.match { filename = filename }
    if filetype and filetype ~= '' and filetype ~= 'txtar' then
      local cluster = included_fts[filetype]
      if not cluster then
        cluster = '@txtar_' .. filetype:gsub('[^%w]', '_')
        syntax_cmd(bufnr, ('silent! syntax include %s syntax/%s.vim'):format(cluster, filetype))
        included_fts[filetype] = cluster
      end

      index = index + 1
      local group = ('txtarEmbedded_%d'):format(index)
      local escaped_filename = escape_vim_pattern(filename)
      syntax_cmd(
        bufnr,
        ([[syntax region %s start=/^--\s\+%s\s\+--$/ end=/\ze^--\s\+\S\+\s\+--$/ keepend contains=txtarArchiveDash,txtarArchiveFilename,%s]]):format(
          group,
          escaped_filename,
          cluster
        )
      )
      table.insert(dynamic_groups, group)
    end
  end

  vim.b[bufnr].txtar_included_fts = included_fts
  vim.b[bufnr].txtar_dynamic_groups = dynamic_groups
end

function M.attach(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].filetype ~= 'txtar' then
    return
  end

  if vim.b[bufnr].txtar_attached then
    M.apply(bufnr)
    return
  end

  vim.b[bufnr].txtar_attached = true
  M.apply(bufnr)

  local group = vim.api.nvim_create_augroup('txtar_syntax_' .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI', 'BufWritePost' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      M.apply(bufnr)
    end,
  })
end

return M
