describe('Metrics', function()
  local Metrics = require('write-it-nvim.metrics')

  describe('calculate_wpm', function()
    it('returns 0 for zero elapsed time', function()
      local start = vim.loop.now()
      local wpm = Metrics.calculate_wpm(start, 50)
      assert.equals(0, wpm)
    end)

    it('calculates WPM correctly for 1 minute', function()
      local start = 0
      local after_1min = 60 * 1000  -- 1 minute in milliseconds

      -- Mock vim.loop.now()
      local original_now = vim.loop.now
      vim.loop.now = function() return after_1min end

      local wpm = Metrics.calculate_wpm(start, 50)  -- 50 chars = 10 words
      assert.equals(10, wpm)

      -- Restore
      vim.loop.now = original_now
    end)

    it('calculates WPM correctly for 30 seconds', function()
      local start = 0
      local after_30sec = 30 * 1000  -- 30 seconds in milliseconds

      -- Mock vim.loop.now()
      local original_now = vim.loop.now
      vim.loop.now = function() return after_30sec end

      local wpm = Metrics.calculate_wpm(start, 25)  -- 25 chars = 5 words, in 0.5 min = 10 WPM
      assert.equals(10, wpm)

      -- Restore
      vim.loop.now = original_now
    end)

    it('calculates WPM correctly for 2 minutes', function()
      local start = 0
      local after_2min = 120 * 1000  -- 2 minutes in milliseconds

      -- Mock vim.loop.now()
      local original_now = vim.loop.now
      vim.loop.now = function() return after_2min end

      local wpm = Metrics.calculate_wpm(start, 100)  -- 100 chars = 20 words, in 2 min = 10 WPM
      assert.equals(10, wpm)

      -- Restore
      vim.loop.now = original_now
    end)
  end)

  describe('calculate_accuracy', function()
    it('returns 100 for no errors', function()
      local accuracy = Metrics.calculate_accuracy(100, 0)
      assert.equals(100, accuracy)
    end)

    it('returns 100 for zero characters', function()
      local accuracy = Metrics.calculate_accuracy(0, 0)
      assert.equals(100, accuracy)
    end)

    it('calculates accuracy correctly', function()
      local accuracy = Metrics.calculate_accuracy(100, 5)
      assert.equals(95, accuracy)
    end)

    it('calculates accuracy correctly for 50% errors', function()
      local accuracy = Metrics.calculate_accuracy(100, 50)
      assert.equals(50, accuracy)
    end)

    it('handles all errors', function()
      local accuracy = Metrics.calculate_accuracy(100, 100)
      assert.equals(0, accuracy)
    end)
  end)

  describe('get_progress', function()
    it('returns 0 for zero total', function()
      local progress = Metrics.get_progress(0, 0)
      assert.equals(0, progress)
    end)

    it('calculates progress correctly', function()
      local progress = Metrics.get_progress(50, 100)
      assert.equals(50, progress)
    end)

    it('calculates progress for 100%', function()
      local progress = Metrics.get_progress(100, 100)
      assert.equals(100, progress)
    end)

    it('calculates progress for partial completion', function()
      local progress = Metrics.get_progress(25, 100)
      assert.equals(25, progress)
    end)
  end)
end)
