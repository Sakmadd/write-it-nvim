describe('Preprocessor', function()
  local Preprocessor = require('write-it-nvim.preprocessor')

  describe('remove_comments', function()
    it('removes JavaScript single-line comments', function()
      local code = [[
function test() {
  // This is a comment
  return true;
}
]]

      local cleaned = Preprocessor.remove_comments(code, 'javascript')
      assert.is_nil(cleaned:match('//'))
      assert.is_not_nil(cleaned:match('function test'))
      assert.is_not_nil(cleaned:match('return true'))
    end)

    it('removes JavaScript multi-line comments', function()
      local code = [[
function test() {
  /* This is a
     multi-line comment */
  return true;
}
]]

      local cleaned = Preprocessor.remove_comments(code, 'javascript')
      assert.is_nil(cleaned:match('/%*'))
      assert.is_not_nil(cleaned:match('function test'))
      assert.is_not_nil(cleaned:match('return true'))
    end)

    it('removes Python comments', function()
      local code = [[
def test():
    # This is a comment
    return True
]]

      local cleaned = Preprocessor.remove_comments(code, 'python')
      assert.is_nil(cleaned:match('#'))
      assert.is_not_nil(cleaned:match('def test'))
      assert.is_not_nil(cleaned:match('return True'))
    end)

    it('removes Lua single-line comments', function()
      local code = [[
function test()
  -- This is a comment
  return true
end
]]

      local cleaned = Preprocessor.remove_comments(code, 'lua')
      assert.is_nil(cleaned:match('%-%-'))
      assert.is_not_nil(cleaned:match('function test'))
      assert.is_not_nil(cleaned:match('return true'))
    end)

    it('removes Lua multi-line comments', function()
      local code = [=[
function test()
  --[[
  This is a
  multi-line comment
  ]]
  return true
end
]=]

      local cleaned = Preprocessor.remove_comments(code, 'lua')
      assert.is_nil(cleaned:match('%-%-%[%['))
      assert.is_not_nil(cleaned:match('function test'))
      assert.is_not_nil(cleaned:match('return true'))
    end)

    it('handles unknown filetypes gracefully', function()
      local code = 'some code'
      local cleaned = Preprocessor.remove_comments(code, 'unknown')
      assert.equals(code, cleaned)
    end)

    it('preserves code without comments', function()
      local code = [[
function test() {
  return true;
}
]]

      local cleaned = Preprocessor.remove_comments(code, 'javascript')
      assert.equals(code, cleaned)
    end)
  end)

  describe('remove_empty_lines', function()
    it('removes empty lines', function()
      local code = "line1\n\nline2\n\n\nline3"
      local cleaned = Preprocessor.remove_empty_lines(code)
      assert.equals("line1\nline2\nline3", cleaned)
    end)

    it('removes lines with only whitespace', function()
      local code = "line1\n   \nline2\n\t\nline3"
      local cleaned = Preprocessor.remove_empty_lines(code)
      assert.equals("line1\nline2\nline3", cleaned)
    end)

    it('preserves code without empty lines', function()
      local code = "line1\nline2\nline3"
      local cleaned = Preprocessor.remove_empty_lines(code)
      assert.equals(code, cleaned)
    end)

    it('handles single line', function()
      local code = "line1"
      local cleaned = Preprocessor.remove_empty_lines(code)
      assert.equals("line1", cleaned)
    end)

    it('handles all empty lines', function()
      local code = "\n\n\n"
      local cleaned = Preprocessor.remove_empty_lines(code)
      assert.equals("", cleaned)
    end)
  end)

  describe('preprocess', function()
    it('applies both comment removal and empty line removal', function()
      local code = [[
// Comment
function test() {

  // Another comment
  return true;
}
]]

      local config = {
        preprocess = {
          remove_comments = true,
          remove_empty_lines = true
        }
      }

      local cleaned = Preprocessor.preprocess(code, 'javascript', config)

      assert.is_nil(cleaned:match('//'))
      assert.is_not_nil(cleaned:match('function test'))
      assert.is_not_nil(cleaned:match('return true'))
      -- Should have fewer lines due to empty line removal
      local line_count = select(2, cleaned:gsub('\n', '\n'))
      assert.is_true(line_count < 5)
    end)

    it('respects config settings', function()
      local code = [[
// Comment
line1

line2
]]

      local config = {
        preprocess = {
          remove_comments = false,
          remove_empty_lines = true
        }
      }

      local cleaned = Preprocessor.preprocess(code, 'javascript', config)

      -- Comment should remain (remove_comments = false)
      assert.is_not_nil(cleaned:match('//'))
      -- Empty lines should be removed
      assert.is_nil(cleaned:match('\n\n'))
    end)

    it('trims whitespace', function()
      local code = "  line1\nline2  "

      local config = {
        preprocess = {
          remove_comments = false,
          remove_empty_lines = false
        }
      }

      local cleaned = Preprocessor.preprocess(code, 'javascript', config)

      -- Leading/trailing whitespace should be trimmed
      assert.equals("line1\nline2", cleaned)
    end)
  end)
end)
