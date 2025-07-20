-- Example configuration for integrating cmp-claudecode with your Neovim setup

-- Basic setup with lazy.nvim
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    local cmp = require('cmp')
    
    -- Setup the plugin (optional, uses defaults)
    require('cmp-claudecode').setup()
    
    -- Register the source
    cmp.register_source('claudecode', require('cmp-claudecode'))
    
    -- Enable for specific filetypes
    cmp.setup.filetype({ 'markdown', 'gitcommit', 'text' }, {
      sources = cmp.config.sources({
        { name = 'claudecode' },
        { name = 'path' },
        { name = 'buffer' },
      })
    })
    
    -- Enable for editprompt buffers
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
  end
}

-- With custom configuration
{
  'biosugar0/cmp-claudecode',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    local cmp = require('cmp')
    
    -- Setup with custom max_items
    require('cmp-claudecode').setup({
      max_items = 100,  -- Only configurable option
    })
    
    -- Register the source
    cmp.register_source('claudecode', require('cmp-claudecode'))
    
    -- Enable for markdown
    cmp.setup.filetype('markdown', {
      sources = {
        { name = 'claudecode' },
        { name = 'buffer' },
        { name = 'path' },
      }
    })
  end
}