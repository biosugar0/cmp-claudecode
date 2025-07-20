# cmp-claudecode

[![CI](https://github.com/biosugar0/cmp-claudecode/workflows/CI/badge.svg)](https://github.com/biosugar0/cmp-claudecode/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.7%2B-green.svg)](https://neovim.io/)

A minimal [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source for Claude Code completions.

## Features

- 📁 **File references with `@`** - Quickly reference project files
- 🎢 **Slash commands with `/`** - Access Claude Code commands

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    -- Setup the plugin
    require('cmp-claudecode').setup()
    
    -- Register the source
    require('cmp').register_source('claudecode', require('cmp-claudecode'))
    
    -- Enable for specific filetypes
    require('cmp').setup.filetype({ 'markdown', 'gitcommit', 'text' }, {
      sources = {
        { name = 'claudecode' },
        { name = 'path' },
        { name = 'buffer' },
      }
    })
  end
}
```

## Usage

### File References

Type `@` to get file path completions:
- `@src/` - Lists files in src directory
- `@test/` - Lists files in test directory
- Works with relative paths

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

```lua
require('cmp-claudecode').setup({
  -- Maximum number of completion items (default: 50)
  max_items = 100,
})
```

That's it! All other settings are optimized internally.

### Performance

This plugin is optimized for performance out of the box:

- **Async Completion**: Non-blocking file system operations
- **Smart Caching**: Automatic caching with memory management
- **Fuzzy Search**: Fast incremental search for better matches
- **Debounced Input**: Prevents excessive completion requests

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

## License

MIT