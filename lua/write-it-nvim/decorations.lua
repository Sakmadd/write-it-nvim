local M = {}

---Setup highlight groups
function M.setup_highlights()
  -- Passed characters: use Normal (preserve syntax highlighting)
  vim.api.nvim_set_hl(0, 'WriteItPassed', { link = 'Normal' })

  -- Error characters: red background with wavy underline
  vim.api.nvim_set_hl(0, 'WriteItError', {
    bg = '#ef4444',
    sp = '#ef4444',
    undercurl = true
  })

  -- Current cursor position: blue underline
  vim.api.nvim_set_hl(0, 'WriteItCursor', {
    underline = true,
    sp = '#60a5fa'
  })

  -- Pending characters on current line: dimmed
  vim.api.nvim_set_hl(0, 'WriteItPending', { link = 'Comment' })

  -- Hidden characters (future lines): fg = bg
  local normal_hl = vim.api.nvim_get_hl_by_name('Normal', true)
  local bg_color = normal_hl.background or 0x000000
  vim.api.nvim_set_hl(0, 'WriteItHidden', {
    fg = string.format('#%06x', bg_color),
    nocombine = true
  })
end

---Apply decorations to the session
---@param session Session
function M.apply_decorations(session)
  local bufnr = session.bufnr
  local ns_id = session.ns_id

  -- Ensure highlights are set up
  M.setup_highlights()

  -- Clear existing decorations
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  -- If finished, only show errors
  if session.finished then
    for i = 1, #session.code do
      local pos = session.char_positions[i]
      local state = session.char_states[i]

      if state == 'error' then
        vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'WriteItError',
          pos.line, pos.col, pos.col + 1)
      end
    end
    return
  end

  -- Determine current line
  local current_line = 0
  if session.current_index > 0 and session.current_index <= #session.char_positions then
    current_line = session.char_positions[session.current_index].line
  elseif session.current_index == 0 and #session.char_positions > 0 then
    current_line = session.char_positions[1].line
  end

  -- Apply decorations based on state
  for i = 1, #session.code do
    local pos = session.char_positions[i]
    local state = session.char_states[i]

    if i == session.current_index + 1 then
      -- Current cursor position
      vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'WriteItCursor',
        pos.line, pos.col, pos.col + 1)

    elseif i <= session.current_index then
      -- Already typed
      if state == 'error' then
        vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'WriteItError',
          pos.line, pos.col, pos.col + 1)
      end
      -- Passed: no highlight (preserve syntax)

    elseif pos.line == current_line then
      -- Pending (same line) - dimmed
      vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'WriteItPending',
        pos.line, pos.col, pos.col + 1)

    else
      -- Future lines - HIDDEN
      vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'WriteItHidden',
        pos.line, pos.col, pos.col + 1)
    end
  end

  -- Move cursor to current position (wrapped in pcall for test compatibility)
  if session.current_index < #session.char_positions then
    local cursor_pos = session.char_positions[session.current_index + 1]
    pcall(vim.api.nvim_win_set_cursor, 0, { cursor_pos.line + 1, cursor_pos.col })
  end
end

return M
