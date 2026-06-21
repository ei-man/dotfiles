return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle DAP UI',
    },

    {
      '<leader>ds',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Stop',
    },
    {
      '<leader>dt',
      function()
        require('dap-go').debug_test()
      end,
      desc = 'Debug: Run test',
    },
    {
      '<leader>dp',
      function()
        require('line-profiler').start()
      end,
      desc = 'Debug: Profile lines',
    },
    {
      '<leader>dP',
      function()
        require('line-profiler').clear()
      end,
      desc = 'Debug: Clear profile',
    },
    {
      '<leader>df',
      function()
        local session = require('dap').session()
        if not session then
          vim.notify('No active DAP session', vim.log.levels.WARN)
          return
        end

        local cexpr = vim.fn.expand '<cexpr>'
        local cword = vim.fn.expand '<cWORD>'
        local expr = cexpr ~= '' and cexpr or cword
        if expr == '' then
          vim.notify('No expression under cursor', vim.log.levels.WARN)
          return
        end

        local function show_in_float(val, title)
          -- Strip surrounding quotes
          if val:sub(1, 1) == '"' and val:sub(-1) == '"' then
            val = val:sub(2, -2)
          end
          -- Unescape string literals
          val = val:gsub('\\n', '\n')
          val = val:gsub('\\t', '\t')
          val = val:gsub('\\"', '"')
          val = val:gsub('\\\\', '\\')

          local lines = vim.split(val, '\n', { plain = true })

          local max_width = math.floor(vim.o.columns * 0.8)
          local max_height = math.floor(vim.o.lines * 0.8)
          local width = 0
          for _, line in ipairs(lines) do
            width = math.max(width, vim.fn.strdisplaywidth(line))
          end
          width = math.max(math.min(width, max_width), 1)
          local height = math.max(math.min(#lines, max_height), 1)

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].bufhidden = 'wipe'

          local win = vim.api.nvim_open_win(buf, true, {
            relative = 'editor',
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            width = width,
            height = height,
            style = 'minimal',
            border = 'rounded',
            title = ' ' .. title .. ' ',
            title_pos = 'center',
          })
          vim.wo[win].wrap = true

          for _, key in ipairs { 'q', '<Esc>' } do
            vim.keymap.set('n', key, function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
            end, { buffer = buf, nowait = true })
          end
        end

        local base_args = {
          frameId = (session.current_frame or {}).id,
          context = 'hover',
          format = { rawString = true },
        }

        local function do_eval(args, cb)
          session:request('evaluate', vim.tbl_extend('force', base_args, args), cb)
        end

        -- Fetch full string by slicing to bypass Delve's MaxStringLen truncation.
        -- Each slice stays under the limit so it won't be truncated.
        local function fetch_full_string(expression, on_done)
          local chunk_size = 400
          do_eval({ expression = 'len(' .. expression .. ')', context = 'repl' }, function(err, resp)
            if err or not resp then
              vim.schedule(function() on_done(nil) end)
              return
            end
            local total_len = tonumber(resp.result)
            if not total_len or total_len == 0 then
              vim.schedule(function() on_done('') end)
              return
            end
            local chunks = {}
            local num_chunks = math.ceil(total_len / chunk_size)
            local received = 0
            for i = 0, num_chunks - 1 do
              local s = i * chunk_size
              local e = math.min(s + chunk_size, total_len)
              do_eval({
                expression = expression .. '[' .. s .. ':' .. e .. ']',
                context = 'repl',
              }, function(cerr, cresp)
                received = received + 1
                if not cerr and cresp then
                  local v = cresp.result or ''
                  if v:sub(1, 1) == '"' and v:sub(-1) == '"' then
                    v = v:sub(2, -2)
                  end
                  chunks[i + 1] = v
                else
                  chunks[i + 1] = ''
                end
                if received == num_chunks then
                  vim.schedule(function() on_done(table.concat(chunks)) end)
                end
              end)
            end
          end)
        end

        local function try_eval(expression, fallback)
          do_eval({ expression = expression }, function(err, resp)
            if err then
              vim.schedule(function()
                if fallback and fallback ~= '' and fallback ~= expression then
                  try_eval(fallback, nil)
                else
                  vim.notify('DAP eval error: ' .. tostring(err), vim.log.levels.ERROR)
                end
              end)
              return
            end

            -- For string types, fetch full value via slicing to avoid truncation
            if resp.type == 'string' then
              fetch_full_string(expression, function(full_val)
                if full_val then
                  show_in_float(full_val, expression)
                else
                  show_in_float(resp.result or '', expression)
                end
              end)
            else
              vim.schedule(function()
                show_in_float(resp.result or '', expression)
              end)
            end
          end)
        end

        try_eval(expr, cword ~= cexpr and cword or nil)
      end,
      desc = 'Debug: Format variable in float',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'delve',
      },
    }

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
        args = { '--check-go-version=false' },
        initialize_timeout_sec = 20,
      },
    }
  end,
}
