-- Example configuration for integrating cmp-claudecode with your Neovim setup

-- Basic setup with lazy.nvim (recommended)
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp' },
  -- No configuration needed! The plugin automatically registers itself.
}

-- After installing, configure nvim-cmp to use claudecode for specific filetypes:
-- (This goes in your nvim-cmp configuration, not in the plugin spec)

local cmp = require('cmp')

-- Enable for specific filetypes
cmp.setup.filetype({ 'markdown', 'gitcommit', 'text' }, {
  sources = cmp.config.sources({
    { name = 'claudecode', priority = 1000 },  -- High priority
    { name = 'copilot' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
  })
})

-- Enable for editprompt buffers (Claude Code integration)
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*/editprompt-*/.editprompt-*.md',
  callback = function()
    cmp.setup.buffer({
      sources = cmp.config.sources({
        { name = 'claudecode', priority = 1000 },
        { name = 'path' },
        { name = 'buffer' },
      })
    })
  end,
})

-- Optional: If you need to customize the plugin settings
-- (This is rarely needed as defaults work well)
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    -- Only call setup if you need to change defaults
    require('cmp-claudecode').setup({
      max_items = 100,  -- Default is 50
    })
  end
}

-- Note: The plugin uses an 'after' directory structure, which means:
-- 1. It automatically calls require('cmp').register_source() 
-- 2. No manual registration is needed
-- 3. The source is available immediately after plugin loads

-- Features:
-- - Type @ to get file completions
-- - Type @. to include hidden files
-- - Type / to get slash command completions
-- - File preview on hover (resolve method)