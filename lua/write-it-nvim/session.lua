---@class Session
---@field bufnr number
---@field code string
---@field filetype string
---@field current_index number
---@field char_states table<number, string>
---@field char_positions table<number, {line: number, col: number}>
---@field errors number
---@field started boolean
---@field finished boolean
---@field start_time number
---@field ns_id number
---@field config table
---@field input_ns_id number|nil

local Session = {}
Session.__index = Session

---Create a new practice session
---@param bufnr number
---@param code string
---@param filetype string
---@param config table
---@return Session
function Session.new(bufnr, code, filetype, config)
  local self = setmetatable({}, Session)

  self.bufnr = bufnr
  self.code = code
  self.filetype = filetype
  self.config = config
  self.current_index = 0
  self.errors = 0
  self.started = false
  self.finished = false
  self.start_time = 0
  self.ns_id = vim.api.nvim_create_namespace('write-it-decorations')

  -- Initialize character states
  self.char_states = {}
  for i = 1, #code do
    self.char_states[i] = 'pending'
  end

  -- Pre-compute character positions
  self.char_positions = self:compute_char_positions()

  return self
end

---Compute positions for each character in the code
---@return table<number, {line: number, col: number}>
function Session:compute_char_positions()
  local positions = {}
  local line, col = 0, 0

  for i = 1, #self.code do
    table.insert(positions, { line = line, col = col })

    if self.code:sub(i, i) == '\n' then
      line = line + 1
      col = 0
    else
      col = col + 1
    end
  end

  return positions
end

---Handle a character input
---@param char string
function Session:handle_char(char)
  if self.finished or self.current_index >= #self.code then return end

  -- Start timer on first keystroke
  if not self.started then
    self.started = true
    self.start_time = vim.loop.now()
  end

  local expected = self.code:sub(self.current_index + 1, self.current_index + 1)

  -- Handle newline
  if char == '\n' then
    if expected == '\n' then
      self.char_states[self.current_index + 1] = 'passed'
      self.current_index = self.current_index + 1
    else
      self.char_states[self.current_index + 1] = 'error'
      self.errors = self.errors + 1
      self.current_index = self.current_index + 1
    end

  -- Regular character
  else
    -- Block typing if expecting newline
    if expected == '\n' then
      self.char_states[self.current_index + 1] = 'error'
      self.errors = self.errors + 1
      return  -- Don't increment - stay on newline
    end

    if char == expected then
      self.char_states[self.current_index + 1] = 'passed'
      self.current_index = self.current_index + 1
    else
      self.char_states[self.current_index + 1] = 'error'
      self.errors = self.errors + 1
      self.current_index = self.current_index + 1
    end
  end

  -- Check if finished
  if self.current_index >= #self.code then
    self:finish()
  else
    self:update_decorations()
    self:update_statusline()
  end
end

---Handle backspace input
function Session:handle_backspace()
  if self.current_index > 0 then
    self.current_index = self.current_index - 1

    -- Decrement errors if was error
    if self.char_states[self.current_index + 1] == 'error' then
      self.errors = self.errors - 1
    end

    self.char_states[self.current_index + 1] = 'pending'
    self:update_decorations()
    self:update_statusline()
  end
end

---Handle delete word input
function Session:handle_delete_word()
  if self.current_index == 0 then return end

  -- Skip trailing whitespace/newlines
  while self.current_index > 0 do
    local prev = self.code:sub(self.current_index, self.current_index)
    if prev ~= ' ' and prev ~= '\n' and prev ~= '\t' then break end
    self:handle_backspace()
  end

  -- Delete until word boundary
  while self.current_index > 0 do
    local prev = self.code:sub(self.current_index, self.current_index)
    if prev == ' ' or prev == '\n' or prev == '\t' then break end
    self:handle_backspace()
  end
end

---Handle tab input
function Session:handle_tab()
  if self.finished or self.current_index >= #self.code then return end

  if not self.started then
    self.started = true
    self.start_time = vim.loop.now()
  end

  local expected = self.code:sub(self.current_index + 1, self.current_index + 1)

  if expected == '\t' then
    -- Exact tab match
    self.char_states[self.current_index + 1] = 'passed'
    self.current_index = self.current_index + 1

  elseif expected == ' ' then
    -- Tab skips up to 4 spaces
    local spaces = 0
    while self.current_index < #self.code
      and self.code:sub(self.current_index + 1, self.current_index + 1) == ' '
      and spaces < 4 do

      self.char_states[self.current_index + 1] = 'passed'
      self.current_index = self.current_index + 1
      spaces = spaces + 1
    end

  else
    -- Error
    self.char_states[self.current_index + 1] = 'error'
    self.errors = self.errors + 1
    self.current_index = self.current_index + 1
  end

  if self.current_index >= #self.code then
    self:finish()
  else
    self:update_decorations()
    self:update_statusline()
  end
end

---Update decorations (will be implemented by decorations module)
function Session:update_decorations()
  local decorations = require('write-it-nvim.decorations')
  decorations.apply_decorations(self)
end

---Update statusline (will be implemented in this module)
function Session:update_statusline()
  local Metrics = require('write-it-nvim.metrics')

  local wpm = 0
  local accuracy = 100
  local progress = 0

  if self.started then
    wpm = Metrics.calculate_wpm(self.start_time, self.current_index)
    accuracy = Metrics.calculate_accuracy(self.current_index, self.errors)
    progress = Metrics.get_progress(self.current_index, #self.code)
  end

  -- Set buffer-local statusline
  vim.api.nvim_buf_set_option(self.bufnr, 'statusline',
    string.format(' Write It: %d%% | %d WPM | %d%% acc',
      progress, wpm, accuracy)
  )
end

---Finish the practice session
function Session:finish()
  self.finished = true

  local Metrics = require('write-it-nvim.metrics')
  local wpm = Metrics.calculate_wpm(self.start_time, #self.code)
  local accuracy = Metrics.calculate_accuracy(#self.code, self.errors)

  -- Update statusline
  vim.api.nvim_buf_set_option(self.bufnr, 'statusline',
    string.format('✓ Write It: Complete | %d WPM | %d%% acc', wpm, accuracy)
  )

  -- Show notification
  vim.notify(
    string.format('🎉 Practice complete! WPM: %d | Accuracy: %d%%', wpm, accuracy),
    vim.log.levels.INFO
  )

  -- Clear cursor/pending decorations
  self:update_decorations()
end

---Reset the practice session
function Session:reset()
  self.current_index = 0
  self.errors = 0
  self.started = false
  self.finished = false
  self.start_time = 0

  -- Reset all states to pending
  for i = 1, #self.code do
    self.char_states[i] = 'pending'
  end

  self:update_decorations()
  self:update_statusline()
end

---Dispose the session and clean up
function Session:dispose()
  -- Clear namespace
  if vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
  end

  -- Remove input handler if exists
  if self.input_ns_id then
    pcall(vim.on_key, nil, self.input_ns_id)
  end
end

return Session
