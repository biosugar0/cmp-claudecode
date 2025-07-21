-- Minimal init.lua for testing cmp-claudecode
vim.g.cmp_claudecode_debug = true

-- Set up plugin paths
local cmp_path = vim.fn.expand('~/.cache/nvim/lazy/nvim-cmp')
local plenary_path = vim.fn.expand('~/.cache/nvim/lazy/plenary.nvim')

if vim.fn.isdirectory(cmp_path) ~= 1 then
  print("Error: nvim-cmp not found at " .. cmp_path)
  return
end
if vim.fn.isdirectory(plenary_path) ~= 1 then
  print("Error: plenary.nvim not found at " .. plenary_path)
  return
end

vim.opt.runtimepath:prepend(cmp_path)
vim.opt.runtimepath:prepend(plenary_path)
vim.opt.runtimepath:prepend(vim.fn.expand('~/ghq/github.com/biosugar0/cmp-claudecode'))

-- Load plugins
local cmp = require('cmp')

-- Register sources manually (since after/plugin won't be loaded)
local slash_source = require('cmp_claudecode.slash')
local at_source = require('cmp_claudecode.at')

cmp.register_source('claude_slash', slash_source)
cmp.register_source('claude_at', at_source)
print("claude_slash and claude_at sources registered")

-- Basic cmp setup
cmp.setup({
  snippet = {
    expand = function(args)
      -- No snippet engine needed for testing
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'claude_slash' },
    { name = 'claude_at' },
  }),
})

-- Test the source
vim.defer_fn(function()
  local sources = cmp.get_registered_sources()
  print("\nRegistered sources:")
  for _, source in ipairs(sources) do
    print("  - " .. source.name)
  end
  
  -- Create a test buffer
  vim.cmd('new')
  vim.bo.filetype = 'markdown'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    "# Test",
    "",
    "Type @ below:",
    "",
  })
  
  -- Verify filetype and config
  print("\nBuffer info:")
  print("  filetype: " .. vim.bo.filetype)
  
  -- Test is_available
  local at_source = require('cmp_claudecode.at')
  local is_avail = at_source:is_available()
  print("  at_source:is_available(): " .. tostring(is_avail))
  
  -- Test keyword pattern
  local pattern = at_source:get_keyword_pattern()
  print("  keyword_pattern: " .. pattern)
  
  -- Test vim regex
  local regex = vim.regex(pattern)
  local test_str = "after/"
  local match = regex:match_str(test_str)
  print("  vim.regex test for 'after/': " .. tostring(match))
  
  print("\nReady to test. Type @ to trigger completion.")
end, 100)