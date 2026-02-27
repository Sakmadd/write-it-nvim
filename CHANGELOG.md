# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of write-it-nvim
- Progressive reveal system (hides future lines)
- Anti-cheat mechanisms (blocks paste, autocomplete, direct modifications)
- Real-time metrics (WPM and accuracy) in statusline
- Visual feedback (error highlighting with red background and wavy underline)
- Code preprocessing (comment and empty line removal)
- Support for multiple programming languages
- Visual mode selection for starting practice
- Commands: `:WriteItStart`, `:WriteItReset`, `:WriteItStop`
- Configurable keymaps and settings
- Full unit test suite
- Comprehensive documentation

### Features
- Character-by-character typing practice
- Syntax highlighting preserved in practice buffer
- Session reset capability
- Delete word functionality (`<C-BS>`)
- Tab handling (matches tab or skips up to 4 spaces)
- Newline handling
- Backspace support with error correction

### Supported Languages
- JavaScript, TypeScript, JSX, TSX
- Java, C, C++, C#
- Go, Rust, Kotlin, Swift, PHP
- Python, Ruby
- Bash, Shell, Zsh
- YAML
- Lua
- HTML, XML
- CSS, SCSS, Less

[Unreleased]: https://github.com/yourusername/write-it-nvim/commits/main
