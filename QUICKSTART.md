# Quick Start Guide

## Installation

Add to your Neovim config (using lazy.nvim):

```lua
{
  'yourusername/write-it-nvim',
  config = function()
    require('write-it-nvim').setup()
  end
}
```

## First Practice Session

1. **Open the test file**:
   ```vim
   :e ~/.local/share/nvim/lazy/write-it-nvim/test_code.lua
   ```
   (Or wherever you installed the plugin)

2. **Select some code** in visual mode:
   - Press `V` to enter visual line mode
   - Move down a few lines to select a function

3. **Start practice**:
   - Press `<leader>wp` (default keymap)
   - OR run `:WriteItStart`

4. **Start typing!**
   - Type the code character-by-character
   - Watch the statusline for your WPM and accuracy
   - Notice how future lines are hidden until you reach them

5. **Controls**:
   - `Backspace` - Undo last character
   - `<C-BS>` or `<C-w>` - Delete entire word
   - `<Esc>` - Reset practice session
   - `<C-S-Esc>` - Stop and close practice

## What You'll See

### Statusline
```
 Write It: 45% | 42 WPM | 98% acc
```

### Visual Feedback
- ✅ **Correct characters**: Normal syntax highlighting
- ❌ **Errors**: Red background with wavy underline
- 📍 **Current position**: Blue underline
- 💭 **Pending (same line)**: Dimmed text
- 🙈 **Future lines**: Hidden (text color = background)

### When Finished
```
✓ Write It: Complete | 42 WPM | 98% acc
🎉 Practice complete! WPM: 42 | Accuracy: 98%
```

## Commands

- `:WriteItStart` - Start practice (select code first)
- `:WriteItReset` - Reset to beginning
- `:WriteItStop` - Close practice session

## Configuration

Customize in your setup:

```lua
require('write-it-nvim').setup({
  preprocess = {
    remove_comments = true,      -- Remove comments
    remove_empty_lines = true    -- Remove empty lines
  },
  keymaps = {
    start = "<leader>wp",        -- Your preferred keymap
    reset = "<Esc>",
    stop = "<C-S-Esc>",
    delete_word = "<C-BS>"
  }
})
```

## Tips

1. **Start small** - Practice with short functions first
2. **Focus on accuracy** - Slow and accurate > fast and sloppy
3. **Use reset** - Don't be afraid to press `<Esc>` and try again
4. **Daily practice** - 10-15 minutes per day builds muscle memory
5. **No cheating!** - The plugin blocks paste/autocomplete for a reason

## Troubleshooting

### "Please select some code first"
- Make sure to select code in visual mode before starting

### "Selected code is empty after preprocessing"
- Your selection only had comments/empty lines
- Try selecting actual code

### Future lines not hidden
- May depend on your colorscheme
- The plugin uses `fg = bg` to hide text
- Works best with solid background colors

### Tests not running
- Install dependencies: `luarocks install --local nlua busted`
- Run: `busted` or `luarocks test --local`

## Example Practice Session

```
1. Select code:      V5j (visual mode, 5 lines down)
2. Start:            <leader>wp
3. Type:             Start typing character by character
4. Make error:       See red highlight
5. Backspace:        Press backspace to fix
6. Continue:         Keep typing
7. Finish:           See final stats
8. Reset:            Press <Esc> to try again
9. Stop:             Press <C-S-Esc> to close
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [example_config.lua](example_config.lua) for configuration options
- Try practicing with different languages
- Adjust preprocessing settings to your preference
- Set your preferred keymaps

Happy typing! 🚀
