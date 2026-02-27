local M = {}

---Create a practice buffer with the given code
---@param code string The code to practice
---@param filetype string The filetype for syntax highlighting
---@return number bufnr The buffer number
function M.create_practice_buffer(code, filetype)
  -- Create scratch buffer
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- Set buffer options
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', filetype)
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')

  -- Set content
  local lines = vim.split(code, '\n', { plain = true })
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

  -- Configure buffer to disable completions
  M.configure_buffer_options(bufnr)

  -- Open in current window
  vim.api.nvim_win_set_buf(0, bufnr)

  return bufnr
end

---Configure buffer options to disable completions and modifications
---@param bufnr number The buffer number
function M.configure_buffer_options(bufnr)
  -- Disable LSP
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    vim.lsp.buf_detach_client(bufnr, client.id)
  end

  -- Disable nvim-cmp if available
  pcall(function()
    vim.api.nvim_buf_set_var(bufnr, 'cmp_enabled', false)
  end)

  -- Disable built-in completion
  vim.api.nvim_buf_set_option(bufnr, 'completefunc', '')
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', '')
end

---Close the practice buffer
---@param bufnr number The buffer number
function M.close_practice_buffer(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

return M
