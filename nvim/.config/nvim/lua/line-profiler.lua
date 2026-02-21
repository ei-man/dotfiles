-- Line profiler: steps through a function via DAP, measuring wall clock time per line.
-- Usage: call start() on any line. If no debug session is running, it sets a
-- breakpoint and launches one. Then it step_overs repeatedly, recording how long
-- each line takes, until the function returns.
local M = {}

local ns = vim.api.nvim_create_namespace('line-profiler')

local state = {
  active = false,
  pending = false, -- waiting for breakpoint hit after auto-launching session
  timings = {},    -- line -> { total_ns, count }
  last_line = nil,
  last_time = nil,
  bufnr = nil,
  func_name = nil,
  source_path = nil,
}

local function format_duration(total_ns)
  local ms = total_ns / 1e6
  if ms >= 1000 then
    return string.format('%.2fs', ms / 1000)
  elseif ms >= 1 then
    return string.format('%.1fms', ms)
  else
    return string.format('%.0fus', total_ns / 1e3)
  end
end

local function record_timing(line, elapsed_ns)
  if not state.timings[line] then
    state.timings[line] = { total_ns = 0, count = 0 }
  end
  state.timings[line].total_ns = state.timings[line].total_ns + elapsed_ns
  state.timings[line].count = state.timings[line].count + 1
end

local function display()
  local bufnr = state.bufnr
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local max_ns = 0
  for _, data in pairs(state.timings) do
    if data.total_ns > max_ns then
      max_ns = data.total_ns
    end
  end

  for line, data in pairs(state.timings) do
    local text = format_duration(data.total_ns)
    if data.count > 1 then
      text = text .. string.format(' (%dx)', data.count)
    end

    local hl = 'DiagnosticHint'
    if max_ns > 0 then
      local ratio = data.total_ns / max_ns
      if ratio > 0.75 then
        hl = 'DiagnosticError'
      elseif ratio > 0.25 then
        hl = 'DiagnosticWarn'
      end
    end

    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, line - 1, 0, {
      virt_text = { { '  ' .. text, hl } },
      virt_text_pos = 'eol',
    })
  end
end

local function begin_profiling(frame)
  state.active = true
  state.bufnr = vim.api.nvim_get_current_buf()
  state.func_name = frame.name
  state.source_path = frame.source and frame.source.path or ''
  state.last_line = frame.line
  state.last_time = vim.uv.hrtime()

  vim.notify('Profiling: ' .. state.func_name)
  require('dap').step_over()
end

local function on_stopped(session, body)
  -- Waiting for breakpoint hit after auto-launching a session
  if state.pending then
    state.pending = false
    if not body or not body.threadId then
      return
    end
    session:request('stackTrace', {
      threadId = body.threadId,
      levels = 1,
    }, function(err, response)
      if err or not response or not response.stackFrames or #response.stackFrames == 0 then
        vim.schedule(function()
          vim.notify('Line profiler: failed to get frame', vim.log.levels.ERROR)
        end)
        return
      end
      vim.schedule(function()
        begin_profiling(response.stackFrames[1])
      end)
    end)
    return
  end

  if not state.active then
    return
  end

  if not body or not body.threadId then
    vim.schedule(function()
      M.stop()
    end)
    return
  end

  if body.reason == 'exception' then
    vim.schedule(function()
      M.stop()
    end)
    return
  end

  session:request('stackTrace', {
    threadId = body.threadId,
    levels = 1,
  }, function(err, response)
    if err or not response or not response.stackFrames or #response.stackFrames == 0 then
      vim.schedule(function()
        M.stop()
      end)
      return
    end

    vim.schedule(function()
      if not state.active then
        return
      end

      local frame = response.stackFrames[1]
      local source_path = frame.source and frame.source.path or ''

      -- Left the original function → done
      if frame.name ~= state.func_name or source_path ~= state.source_path then
        local profiled_bufnr = state.bufnr
        M.stop()
        -- Navigate back to the profiled file instead of staying in Go internals
        if profiled_bufnr and vim.api.nvim_buf_is_valid(profiled_bufnr) then
          vim.api.nvim_set_current_buf(profiled_bufnr)
        end
        return
      end

      -- Record timing for the previous line
      local now = vim.uv.hrtime()
      if state.last_line then
        record_timing(state.last_line, now - state.last_time)
        display()
      end

      -- Fresh timestamp (excludes display overhead)
      state.last_line = frame.line
      state.last_time = vim.uv.hrtime()

      require('dap').step_over()
    end)
  end)
end

local listeners_registered = false

local function ensure_listeners()
  if listeners_registered then
    return
  end
  listeners_registered = true

  local dap = require('dap')
  dap.listeners.after.event_stopped['line-profiler'] = on_stopped
  dap.listeners.before.event_terminated['line-profiler'] = function()
    if state.active then
      vim.schedule(function()
        M.stop()
      end)
    end
  end
  dap.listeners.before.event_exited['line-profiler'] = function()
    if state.active then
      vim.schedule(function()
        M.stop()
      end)
    end
  end
end

function M.start()
  if state.active then
    M.stop()
    return
  end

  M.clear()
  ensure_listeners()

  local dap = require('dap')
  local session = dap.session()

  if session then
    -- Active session: profile from current stopped position
    local frame = session.current_frame
    if not frame then
      vim.notify('No current frame', vim.log.levels.WARN)
      return
    end
    begin_profiling(frame)
  else
    -- No session: set breakpoint on cursor line, launch, profile on hit
    state.pending = true
    dap.set_breakpoint()
    local filepath = vim.fn.expand('%')
    if filepath:match('_test%.go$') then
      require('dap-go').debug_test()
    else
      dap.continue()
    end
  end
end

function M.stop()
  if not state.active then
    return
  end
  state.active = false

  if state.last_line then
    record_timing(state.last_line, vim.uv.hrtime() - state.last_time)
    state.last_line = nil
  end

  display()
  vim.notify('Profiling complete')
end

function M.clear()
  state.active = false
  state.pending = false
  state.timings = {}
  state.last_line = nil
  state.last_time = nil
  state.func_name = nil
  state.source_path = nil
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    vim.api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
  end
  state.bufnr = nil
end

return M
