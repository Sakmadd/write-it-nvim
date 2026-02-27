local M = {}
local config = require('write-it-nvim.config')
local session = nil

---Setup the plugin
---@param opts table|nil Configuration options
function M.setup(opts)
  config.setup(opts)

  -- Mark that setup was called
  vim.g.write_it_nvim_setup_done = true

  -- Register commands
  vim.api.nvim_create_user_command('WriteItStart', function()
    M.start_with_selection()
  end, { range = true, desc = 'Write It: Start practice with visual selection' })

  vim.api.nvim_create_user_command('WriteItReset', function()
    M.reset()
  end, { desc = 'Write It: Reset current practice session' })

  vim.api.nvim_create_user_command('WriteItStop', function()
    M.stop()
  end, { desc = 'Write It: Stop current practice session' })

  -- Global keybinding for starting practice
  vim.keymap.set('v', config.options.keymaps.start, ':WriteItStart<CR>',
    { desc = 'Write It: Start practice' })
end

---Start practice with visual selection
function M.start_with_selection()
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

  if #lines == 0 then
    vim.notify('Please select some code first', vim.log.levels.WARN)
    return
  end

  -- Handle partial line selections
  if #lines == 1 then
    -- Single line selection
    local line = lines[1]
    local start_col = start_pos[3] - 1
    local end_col = end_pos[3]
    lines[1] = line:sub(start_col + 1, end_col)
  else
    -- Multi-line selection
    -- First line: from start_col to end
    local first_line = lines[1]
    local start_col = start_pos[3] - 1
    lines[1] = first_line:sub(start_col + 1)

    -- Last line: from start to end_col
    local last_line = lines[#lines]
    local end_col = end_pos[3]
    lines[#lines] = last_line:sub(1, end_col)
  end

  local code = table.concat(lines, '\n')
  local filetype = vim.bo.filetype

  -- Preprocess
  local Preprocessor = require('write-it-nvim.preprocessor')
  code = Preprocessor.preprocess(code, filetype, config.options)

  if #code == 0 then
    vim.notify('Selected code is empty after preprocessing', vim.log.levels.WARN)
    return
  end

  -- Dispose existing session
  if session then
    session:dispose()
  end

  -- Create buffer
  local Buffer = require('write-it-nvim.buffer')
  local bufnr = Buffer.create_practice_buffer(code, filetype)

  -- Create session
  local Session = require('write-it-nvim.session')
  session = Session.new(bufnr, code, filetype, config.options)

  -- Setup input handlers
  local Input = require('write-it-nvim.input')
  Input.setup_handlers(bufnr, session)

  -- Initial decorations and statusline
  session:update_decorations()
  session:update_statusline()

  -- Show start message
  vim.notify('✨ Practice started! Start typing...', vim.log.levels.INFO)
end

---Reset the current practice session
function M.reset()
  if session then
    session:reset()
    vim.notify('🔄 Session reset!', vim.log.levels.INFO)
  else
    vim.notify('No active practice session', vim.log.levels.WARN)
  end
end

---Stop the current practice session
function M.stop()
  if session then
    local bufnr = session.bufnr
    session:dispose()
    session = nil

    -- Close buffer
    local Buffer = require('write-it-nvim.buffer')
    Buffer.close_practice_buffer(bufnr)

    vim.notify('Practice session stopped', vim.log.levels.INFO)
  else
    vim.notify('No active practice session', vim.log.levels.WARN)
  end
end

return M
