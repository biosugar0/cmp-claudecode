-- after/plugin/cmp_claudecode.lua
local cmp = require('cmp')

for _, name in ipairs({ 'slash', 'at' }) do
  cmp.register_source('claude_' .. name, require('cmp_claudecode.' .. name))
end