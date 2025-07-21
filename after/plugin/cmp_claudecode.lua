-- after/plugin/cmp_claudecode.lua
-- nvim-cmpがロードされた後に実行される

local ok, cmp = pcall(require, 'cmp')
if not ok then
  return
end

-- plenary.nvimの確認
local plenary_ok = pcall(require, 'plenary.scandir')
if not plenary_ok then
  vim.notify('[cmp-claudecode] plenary.nvim is required', vim.log.levels.WARN)
  return
end

-- デバッグ用通知（開発時のみ）
if vim.g.cmp_claudecode_debug then
  vim.notify('[cmp-claudecode] after/plugin loaded', vim.log.levels.INFO)
end

-- 2つのソースを登録
-- nvim-cmpは同名ソースの再登録を自動的に処理するため、二重登録ガードは不要
local slash_source = require('cmp_claudecode.slash')
local at_source = require('cmp_claudecode.at')

-- ソースにnew()メソッドがない場合は追加
if not slash_source.new then
  slash_source.new = function() return slash_source end
end
if not at_source.new then
  at_source.new = function() return at_source end
end

cmp.register_source('claude_slash', slash_source)
cmp.register_source('claude_at', at_source)

if vim.g.cmp_claudecode_debug then
  vim.notify('[cmp-claudecode] Sources registered', vim.log.levels.INFO)
end