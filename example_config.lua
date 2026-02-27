-- Example configuration for write-it-nvim
-- Add this to your Neovim config (init.lua or plugin config)

return {
  'yourusername/write-it-nvim',
  config = function()
    require('write-it-nvim').setup({
      highlights = {
        passed = "Normal",           -- Passed characters (syntax highlighting preserved)
        error = "ErrorMsg",           -- Error highlight base
        cursor = "CursorLine",        -- Current cursor position
        pending = "Comment",          -- Pending characters on current line
        hidden = { fg = "bg" }        -- Hidden future lines (fg = bg color)
      },
      preprocess = {
        remove_comments = true,       -- Remove comments from practice code
        remove_empty_lines = true     -- Remove empty lines from practice code
      },
      keymaps = {
        start = "<leader>wp",         -- Start practice with selection
        reset = "<Esc>",              -- Reset practice session
        stop = "<C-S-Esc>",           -- Stop practice session
        delete_word = "<C-BS>"        -- Delete word
      }
    })
  end
}

-- Usage:
-- 1. Select code in visual mode
-- 2. Press <leader>wp (or your configured keymap)
-- 3. Start typing!
-- 4. Press <Esc> to reset
-- 5. Press <C-S-Esc> to stop

-- Commands:
-- :WriteItStart - Start practice with current visual selection
-- :WriteItReset - Reset current practice session
-- :WriteItStop  - Stop practice session
