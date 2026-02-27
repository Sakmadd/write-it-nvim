local M = {}

---Setup input handlers for the practice buffer
---@param bufnr number
---@param session Session
function M.setup_handlers(bufnr, session)
  -- Block paste commands
  local opts = { buffer = bufnr, noremap = true, silent = true }

  vim.keymap.set({'n', 'i', 'v'}, '<C-v>', function()
    vim.notify('⚠️  Paste blocked!', vim.log.levels.WARN)
  end, opts)

  vim.keymap.set({'n', 'i', 'v'}, 'p', function()
    vim.notify('⚠️  Paste blocked!', vim.log.levels.WARN)
  end, opts)

  vim.keymap.set({'n', 'i', 'v'}, 'P', function()
    vim.notify('⚠️  Paste blocked!', vim.log.levels.WARN)
  end, opts)

  vim.keymap.set({'n', 'i', 'v'}, '"+p', function()
    vim.notify('⚠️  Paste blocked!', vim.log.levels.WARN)
  end, opts)

  vim.keymap.set({'n', 'i', 'v'}, '"*p', function()
    vim.notify('⚠️  Paste blocked!', vim.log.levels.WARN)
  end, opts)

  -- Setup keymaps from config
  local config = session.config

  vim.keymap.set('n', config.keymaps.reset, function()
    session:reset()
  end, { buffer = bufnr, desc = 'Write It: Reset practice' })

  vim.keymap.set('n', config.keymaps.stop, function()
    require('write-it-nvim').stop()
  end, { buffer = bufnr, desc = 'Write It: Stop practice' })

  -- Prevent buffer modifications via autocmd
  vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
    buffer = bufnr,
    callback = function()
      -- Revert to original code
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
      local lines = vim.split(session.code, '\n', { plain = true })
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

      vim.notify('⚠️  Direct modification blocked!', vim.log.levels.WARN)
    end
  })

  -- Setup vim.on_key handler for character input
  local input_ns_id = vim.api.nvim_create_namespace('write-it-input')

  vim.on_key(function(key)
    -- Only process in practice buffer
    if vim.api.nvim_get_current_buf() ~= bufnr then return end
    if session.finished then return end

    -- Get the actual character
    local char = vim.fn.keytrans(key)

    -- Handle special keys
    if char == '<BS>' then
      session:handle_backspace()
    elseif char == '<Tab>' then
      session:handle_tab()
    elseif char == '<CR>' then
      session:handle_char('\n')
    elseif char == config.keymaps.delete_word or char == '<C-BS>' then
      session:handle_delete_word()
    else
      -- Try to convert to actual character
      local ok, actual_char = pcall(vim.fn.nr2char, vim.fn.char2nr(key))
      if ok and #actual_char == 1 then
        -- Check if it's a printable character or space
        if actual_char:match('%g') or actual_char == ' ' then
          session:handle_char(actual_char)
        end
      end
    end
  end, input_ns_id)

  -- Store namespace ID for cleanup
  session.input_ns_id = input_ns_id
end

return M
