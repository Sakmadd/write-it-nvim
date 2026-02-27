# write-it-nvim

A Neovim plugin for code typing practice. Write code character-by-character to build muscle memory and deep understanding - no copy-pasting, no AI autocomplete.

Inspired by the VSCode "Write It" extension.

## Features

- **Progressive Reveal**: Only the current line is visible; future lines are hidden until you reach them
- **Anti-Cheat System**: Blocks paste, autocomplete, and direct buffer modifications
- **Real-Time Metrics**: See your WPM (words per minute) and accuracy in the statusline
- **Visual Feedback**: Errors are highlighted with red backgrounds and wavy underlines
- **Code Preprocessing**: Automatically removes comments and empty lines (configurable)
- **Syntax Highlighting**: Practice buffer maintains syntax highlighting for better readability

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'yourusername/write-it-nvim',
  config = function()
    require('write-it-nvim').setup()
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'yourusername/write-it-nvim',
  config = function()
    require('write-it-nvim').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'yourusername/write-it-nvim'

" In your init.lua or in a lua block:
lua require('write-it-nvim').setup()
```

## Usage

1. **Select code** in visual mode (any code block you want to practice)
2. **Start practice** by pressing `<leader>wp` (or run `:WriteItStart`)
3. **Type the code** character-by-character
4. **Reset** by pressing `<Esc>` to start over
5. **Stop** by pressing `<C-S-Esc>` to close the practice session

### Commands

- `:WriteItStart` - Start practice with current visual selection
- `:WriteItReset` - Reset current practice session to the beginning
- `:WriteItStop` - Stop and close the practice session

### Keymaps (in practice buffer)

- `<Esc>` - Reset practice session
- `<C-S-Esc>` - Stop practice session
- `<C-BS>` or `<C-w>` - Delete entire word
- Regular typing, backspace, tab, and enter work as expected

## Configuration

Default configuration:

```lua
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
    delete_word = "<C-BS>"        -- Delete word (alternative to default <C-w>)
  }
})
```

## How It Works

1. **Select code** to practice (in visual mode)
2. Plugin **preprocesses** the code (removes comments and empty lines if configured)
3. A **scratch buffer** is created with the code
4. **Progressive reveal** hides future lines by setting text color to background color
5. **Input interception** via `vim.on_key()` captures your keystrokes
6. **Real-time feedback**:
   - Correct characters: no highlight (syntax preserved)
   - Errors: red background with wavy underline
   - Current position: blue underline
   - Pending characters: dimmed (Comment highlight)
   - Future lines: hidden (text color = background color)
7. **Metrics** are calculated and displayed in the statusline

## Anti-Cheat Mechanisms

- **Paste blocked**: `Ctrl+V`, `p`, `P`, and clipboard paste are disabled
- **Autocomplete disabled**: LSP, nvim-cmp, and built-in completion are disabled
- **Buffer modifications blocked**: Direct buffer edits are prevented and reverted
- **Read-only buffer**: Buffer is marked as non-modifiable

## Progressive Reveal

Only characters on the current line are visible:
- **Typed characters**: Normal syntax highlighting (or red if error)
- **Current character**: Blue underline
- **Pending characters (same line)**: Dimmed (Comment highlight)
- **Future lines**: Hidden (text color = background color)

As you complete each line, the next line becomes visible.

## Metrics

The statusline shows:
- **Progress**: Percentage of code completed
- **WPM**: Words per minute (5 characters = 1 word)
- **Accuracy**: Percentage of correct characters

Example: ` Write It: 45% | 42 WPM | 98% acc`

When finished: `✓ Write It: Complete | 42 WPM | 98% acc`

## Tips

- **Start small**: Practice with short functions or code snippets
- **Focus on accuracy**: High WPM with low accuracy isn't useful
- **Use reset liberally**: Press `<Esc>` to reset and try again
- **Disable preprocessing**: If you want to practice with comments, set `remove_comments = false`
- **Practice daily**: Build muscle memory through consistent practice

## Development

### Run Tests

Tests require [luarocks](https://luarocks.org), [busted](https://lunarmodules.github.io/busted/), and [nlua](https://github.com/mfussenegger/nlua).

```bash
# Install dependencies
luarocks install --local nlua
luarocks install --local busted

# Run tests
luarocks test --local
# or
busted
```

### Run Linter

```bash
luacheck lua/
```

## Supported Languages

Comment removal is supported for:

- **C-style**: JavaScript, TypeScript, Java, C, C++, C#, Go, Rust, Kotlin, Swift, PHP
- **Python-style**: Python, Ruby, Shell, Bash, YAML
- **Lua**: Lua (single and multi-line comments)
- **HTML/XML**: HTML, XML
- **CSS**: CSS, SCSS, Less

## Known Limitations

- **Hidden lines**: Uses `fg = bg` which may not work perfectly with all colorschemes
- **No session persistence**: Practice sessions are ephemeral (not saved between sessions)
- **Input interception**: `vim.on_key()` is global; requires buffer filtering

## Future Enhancements

- Treesitter-based comment removal (more accurate)
- Custom practice snippets library
- Difficulty levels (beginner/advanced snippets)
- Daily challenge mode
- Practice history tracking
- Configurable highlight colors
- Multi-user leaderboards

## License

MIT

## Credits

Inspired by the VSCode "Write It" extension.
