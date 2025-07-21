# cmp-claudecode

[![CI](https://github.com/biosugar0/cmp-claudecode/workflows/CI/badge.svg)](https://github.com/biosugar0/cmp-claudecode/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.7%2B-green.svg)](https://neovim.io/)

A minimal [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source for Claude Code completions.

## Features

- 📁 **File references with `@`** - Quickly reference project files
  - `@.` prefix shows hidden files dynamically
- 🎢 **Slash commands with `/`** - Access Claude Code commands
- 📄 **File preview** - Preview file contents on hover
- 🚀 **Zero configuration** - Works out of the box with automatic registration

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp' },
  -- No setup required! The plugin automatically registers itself.
}
```

The plugin will be automatically available in nvim-cmp. You can configure it for specific filetypes:

```lua
-- In your cmp configuration
require('cmp').setup.filetype({ 'markdown', 'gitcommit', 'text' }, {
  sources = {
    { name = 'claudecode', priority = 1000 },
    { name = 'path' },
    { name = 'buffer' },
  }
})
```

## Usage

### File References

Type `@` to get file path completions:
- `@src/` - Lists files in src directory
- `@test/` - Lists files in test directory
- `@.` - Shows hidden files (dotfiles)
- Works with relative paths
- File preview available on hover

### Slash Commands

Type `/` to see available Claude Code commands:

**Built-in commands:**
- `/help` - Get usage help
- `/clear` - Clear conversation history
- `/model` - Select or change the AI model
- And many more...

**Custom commands:**
- Automatically discovers commands from:
  - `.claude/commands/` (project-specific)
  - `~/.claude/commands/` (user-specific, default)
  - `$CLAUDE_CONFIG_DIR/commands/` (if environment variable is set)
- Supports namespacing with subdirectories (e.g., `/frontend:component`)

## Configuration

No configuration required! The plugin works out of the box with markdown files by default.

If you need to customize settings:

```lua
-- Optional: Only if you need to change defaults
require('cmp_claudecode').setup({
  -- Enable for specific filetypes (default: { 'markdown' })
  enabled = {
    filetypes = { 'terminal', 'markdown', 'gitcommit', 'text' },
  },
  -- Maximum number of completion items (default: 200)
  max_items = 200,
})
```

For detailed configuration options, see [README_CONFIG.md](./README_CONFIG.md).

### Performance

This plugin is optimized for simplicity and performance:

- **Synchronous Operations**: Fast, simple file system scanning inspired by cmp-path
- **Smart Filtering**: Efficient prefix and substring matching
- **Hidden Files**: Dynamic hidden file display with `@.` prefix
- **Minimal Dependencies**: No external dependencies beyond nvim-cmp

## Debugging

Enable debug mode to troubleshoot issues:

```lua
vim.g.cmp_claudecode_debug = true
```

To debug slash command completion issues:
```vim
:lua vim.g.cmp_claudecode_debug = true
" Type / and then /h to see debug messages
:messages
```

For detailed debugging instructions and LazyVim-specific troubleshooting, see [DEBUG.md](./DEBUG.md).

## License

MIT