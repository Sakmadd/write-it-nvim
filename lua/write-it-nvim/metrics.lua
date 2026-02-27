local M = {}

---Calculate words per minute
---@param start_time number Start time in milliseconds
---@param char_count number Number of characters typed
---@return number WPM
function M.calculate_wpm(start_time, char_count)
  local elapsed_minutes = (vim.loop.now() - start_time) / 1000 / 60
  if elapsed_minutes == 0 then return 0 end

  local words = char_count / 5  -- 5 chars = 1 word (standard)
  return math.floor(words / elapsed_minutes)
end

---Calculate accuracy percentage
---@param total_chars number Total characters attempted
---@param errors number Number of errors
---@return number Accuracy percentage
function M.calculate_accuracy(total_chars, errors)
  if total_chars == 0 then return 100 end
  return math.floor(((total_chars - errors) / total_chars) * 100)
end

---Calculate progress percentage
---@param current number Current position
---@param total number Total characters
---@return number Progress percentage
function M.get_progress(current, total)
  if total == 0 then return 0 end
  return math.floor((current / total) * 100)
end

return M
