-- Dynamic syntax injection for embedded files in txtar archives.
-- Scans the buffer for archive headers (-- filename.ext --) and injects
-- the appropriate Vim syntax for each file's extension.

local M = {}

local ext_to_syntax = {
  yaml = "yaml",
  yml = "yaml",
  json = "json",
  toml = "toml",
  go = "go",
  py = "python",
  lua = "lua",
  sh = "sh",
  bash = "sh",
  js = "javascript",
  ts = "typescript",
  md = "markdown",
  rb = "ruby",
  rs = "rust",
  c = "c",
  h = "c",
  cpp = "cpp",
  sql = "sql",
  xml = "xml",
  html = "html",
  css = "css",
  vim = "vim",
  conf = "conf",
  ini = "dosini",
  cfg = "cfg",
}

function M.inject()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Collect unique syntax types from archive headers
  local seen = {}
  for _, line in ipairs(lines) do
    local filename = line:match("^%-%- (.+) %-%-$")
    if filename then
      local ext = filename:match("%.([^.]+)$")
      if ext then
        local syn = ext_to_syntax[ext]
        if syn then
          seen[syn] = true
        end
      end
    end
  end

  -- For each syntax type, include it and define regions
  for syn, _ in pairs(seen) do
    local group = "@txtar_" .. syn

    -- Build escaped extension alternation for Vim regex
    local exts = {}
    for ext, s in pairs(ext_to_syntax) do
      if s == syn then
        table.insert(exts, (ext:gsub("%.", "\\.")))
      end
    end
    local ext_pattern = table.concat(exts, "\\|")

    -- Save and clear b:current_syntax so included syntax files don't bail out
    local saved_syntax = vim.b.current_syntax
    vim.b.current_syntax = nil

    -- Include the syntax file into a cluster
    local ok = pcall(vim.cmd, "syntax include " .. group .. " syntax/" .. syn .. ".vim")

    -- Restore b:current_syntax
    vim.b.current_syntax = saved_syntax

    if ok then
      local region_name = "txtarRegion_" .. syn:gsub("%W", "_")
      -- Region spans from a matching header to the next header or end of file
      vim.cmd(string.format(
        [[syntax region %s matchgroup=txtarFileHeader start="^-- .\+\.\(%s\) --$" end="^-- .\+ --$"me=s-1 end="\%%$" contains=%s keepend]],
        region_name,
        ext_pattern,
        group
      ))
    end
  end
end

return M
