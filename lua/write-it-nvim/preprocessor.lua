local M = {}

-- Language-specific comment patterns
local PATTERNS = {
  -- JavaScript, TypeScript, Java, C, C++, C#, Go, Rust, Kotlin, Swift, PHP
  javascript = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  typescript = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  typescriptreact = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  javascriptreact = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  java = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  c = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  cpp = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  rust = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  go = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  kotlin = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  swift = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  php = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  cs = { single = '//', multi_start = '/%*', multi_end = '%*/' },

  -- Python, Ruby, Shell, YAML
  python = { single = '#' },
  ruby = { single = '#' },
  sh = { single = '#' },
  bash = { single = '#' },
  yaml = { single = '#' },
  zsh = { single = '#' },

  -- Lua
  lua = { single = '%-%-', multi_start = '%-%-%[%[', multi_end = '%]%]' },

  -- HTML, XML
  html = { multi_start = '<!%-%-', multi_end = '%-%->' },
  xml = { multi_start = '<!%-%-', multi_end = '%-%->' },

  -- CSS
  css = { multi_start = '/%*', multi_end = '%*/' },
  scss = { single = '//', multi_start = '/%*', multi_end = '%*/' },
  less = { single = '//', multi_start = '/%*', multi_end = '%*/' },
}

---Remove comments from code
---@param code string
---@param filetype string
---@return string
function M.remove_comments(code, filetype)
  local pattern = PATTERNS[filetype]
  if not pattern then return code end

  -- Remove multi-line comments
  if pattern.multi_start and pattern.multi_end then
    code = code:gsub(pattern.multi_start .. '.-' .. pattern.multi_end, '')
  end

  -- Remove single-line comments
  if pattern.single then
    local lines = vim.split(code, '\n', { plain = true })
    local cleaned = {}

    for _, line in ipairs(lines) do
      -- Remove comment from line but preserve the line itself
      local cleaned_line = line:gsub(pattern.single .. '.*$', '')
      table.insert(cleaned, cleaned_line)
    end

    code = table.concat(cleaned, '\n')
  end

  return code
end

---Remove empty lines from code
---@param code string
---@return string
function M.remove_empty_lines(code)
  local lines = vim.split(code, '\n', { plain = true })
  local filtered = {}

  for _, line in ipairs(lines) do
    -- Keep lines that have at least one non-whitespace character
    if line:match('%S') then
      table.insert(filtered, line)
    end
  end

  return table.concat(filtered, '\n')
end

---Preprocess code according to configuration
---@param code string
---@param filetype string
---@param config table
---@return string
function M.preprocess(code, filetype, config)
  if config.preprocess.remove_comments then
    code = M.remove_comments(code, filetype)
  end

  if config.preprocess.remove_empty_lines then
    code = M.remove_empty_lines(code)
  end

  return vim.trim(code)
end

return M
