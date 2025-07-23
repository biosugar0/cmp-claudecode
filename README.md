# cmp-claudecode

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A minimal [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source for Claude Code completions.

## Features

- 📁 **File references with `@`** - Quickly reference project files
  - `@.` and `@path/.` show hidden files per directory
- 🎢 **Slash commands with `/`** - Access Claude Code commands
- 📄 **File preview** - Preview file contents on hover

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp', 'nvim-lua/plenary.nvim' },
}
```

Or with custom configuration (e.g., for editprompt integration):

```lua
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp', 'nvim-lua/plenary.nvim' },
  opts = {
    enabled = {
      custom = function()
        return vim.env.EDITPROMPT == '1'
      end,
    },
  },
}
```

The plugin will be automatically available in nvim-cmp. You can configure it for specific filetypes:

```lua
-- In your cmp configuration
require('cmp').setup({
  sources = {
    { name = 'claude_slash', priority = 900 },
    { name = 'claude_at', priority = 900 },
    { name = 'path' },
    { name = 'buffer' },
    -- other sources...
  }
})
```

## Usage

### File References

Type `@` to get file path completions:
- `@src/` - Lists files in src directory
- `@test/` - Lists files in test directory
- `@.` - Shows hidden files in root directory
- `@src/.` - Shows hidden files in src directory
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

No configuration required! The plugin works out of the box for all file types by default.

If you need to customize settings:

```lua
-- Optional: Only if you need to change defaults
require('cmp_claudecode').setup({
  enabled = {
    -- Restrict to specific filetypes (default: nil = all filetypes)
    filetypes = { 'terminal', 'markdown', 'gitcommit', 'text' },
    
    -- Or use a custom function for more control
    -- custom = function()
    --   -- Enable only when launched by editprompt
    --   return vim.env.EDITPROMPT == '1'
    -- end,
  },
  
  -- Maximum number of completion items (default: 200)
  max_items = 200,
  
  -- Scan hidden files (default: false)
  scan_hidden = false,
  
  -- Respect .gitignore (default: true)
  respect_gitignore = true,
  
  -- Maximum file size for scanning in bytes (default: 1MB)
  max_file_size = 1024 * 1024,
})
```


### Performance

This plugin is optimized for simplicity and performance:

- **Synchronous Operations**: Fast, simple file system scanning inspired by cmp-path
- **Smart Filtering**: Efficient prefix and substring matching
- **Hidden Files**: Dynamic per-directory display with `@path/.` pattern or global with `scan_hidden` option
- **Minimal Dependencies**: Only requires nvim-cmp and plenary.nvim

## License

MIT
