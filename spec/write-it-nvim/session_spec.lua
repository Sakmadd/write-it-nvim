describe('Session', function()
  local Session = require('write-it-nvim.session')

  before_each(function()
    -- Create a minimal config
    _G.test_config = {
      highlights = {},
      preprocess = {},
      keymaps = {}
    }
  end)

  it('initializes correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'abc', 'lua', _G.test_config)

    assert.equals(bufnr, session.bufnr)
    assert.equals('abc', session.code)
    assert.equals('lua', session.filetype)
    assert.equals(0, session.current_index)
    assert.equals(0, session.errors)
    assert.is_false(session.started)
    assert.is_false(session.finished)
    assert.equals(3, #session.char_states)
    assert.equals(3, #session.char_positions)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('computes character positions correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'ab\ncd', 'lua', _G.test_config)

    assert.equals(5, #session.char_positions)

    -- 'a' at line 0, col 0
    assert.equals(0, session.char_positions[1].line)
    assert.equals(0, session.char_positions[1].col)

    -- 'b' at line 0, col 1
    assert.equals(0, session.char_positions[2].line)
    assert.equals(1, session.char_positions[2].col)

    -- '\n' at line 0, col 2
    assert.equals(0, session.char_positions[3].line)
    assert.equals(2, session.char_positions[3].col)

    -- 'c' at line 1, col 0
    assert.equals(1, session.char_positions[4].line)
    assert.equals(0, session.char_positions[4].col)

    -- 'd' at line 1, col 1
    assert.equals(1, session.char_positions[5].line)
    assert.equals(1, session.char_positions[5].col)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('tracks passed characters correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'abc', 'lua', _G.test_config)

    session:handle_char('a')
    assert.equals(1, session.current_index)
    assert.equals('passed', session.char_states[1])
    assert.equals(0, session.errors)
    assert.is_true(session.started)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('tracks errors correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'abc', 'lua', _G.test_config)

    session:handle_char('x')
    assert.equals(1, session.current_index)
    assert.equals('error', session.char_states[1])
    assert.equals(1, session.errors)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('handles backspace correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'abc', 'lua', _G.test_config)

    session:handle_char('x')  -- Error
    assert.equals(1, session.errors)

    session:handle_backspace()
    assert.equals(0, session.current_index)
    assert.equals('pending', session.char_states[1])
    assert.equals(0, session.errors)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('handles multiple characters correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'abc', 'lua', _G.test_config)

    session:handle_char('a')
    session:handle_char('b')
    session:handle_char('c')

    assert.equals(3, session.current_index)
    assert.equals('passed', session.char_states[1])
    assert.equals('passed', session.char_states[2])
    assert.equals('passed', session.char_states[3])
    assert.equals(0, session.errors)
    assert.is_true(session.finished)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('handles newlines correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'a\nb', 'lua', _G.test_config)

    session:handle_char('a')
    session:handle_char('\n')
    session:handle_char('b')

    assert.equals(3, session.current_index)
    assert.equals('passed', session.char_states[1])
    assert.equals('passed', session.char_states[2])
    assert.equals('passed', session.char_states[3])
    assert.equals(0, session.errors)

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('resets correctly', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local session = Session.new(bufnr, 'abc', 'lua', _G.test_config)

    session:handle_char('a')
    session:handle_char('x')  -- Error

    session:reset()

    assert.equals(0, session.current_index)
    assert.equals(0, session.errors)
    assert.is_false(session.started)
    assert.is_false(session.finished)
    assert.equals('pending', session.char_states[1])
    assert.equals('pending', session.char_states[2])

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
