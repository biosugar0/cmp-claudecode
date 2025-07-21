-- lua/cmp_claudecode/init.lua
-- プラグインのメインエントリーポイント
local M = {}

-- セットアップ関数（オプション）
-- ユーザーが設定をカスタマイズしたい場合に使用
function M.setup(opts)
  require('cmp_claudecode.config').setup(opts)
end

-- ゼロコンフィグでも動作
-- after/plugin/cmp_claudecode.luaが自動的にソースを登録する

return M