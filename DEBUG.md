# cmp-claudecode デバッグガイド

## LazyVimでの動作確認手順

### 1. プラグインのロード確認
```vim
:Lazy
```
- cmp-claudecodeが「loaded」になっているか確認

### 2. after/pluginの実行確認
デバッグモードを有効にして確認：
```lua
:lua vim.g.cmp_claudecode_debug = true
:Lazy reload cmp-claudecode
```
- `[cmp-claudecode] after/plugin loaded` の通知が表示されるか確認

### 3. ソース登録の確認
```lua
-- 登録されているソース一覧を表示
:lua print(vim.inspect(vim.tbl_map(function(s) return s.name end, require('cmp').get_sources())))

-- claude_slashソースの確認
:lua print(require('cmp').get_source('claude_slash') ~= nil)

-- claude_atソースの確認
:lua print(require('cmp').get_source('claude_at') ~= nil)
```

### 4. 補完動作の確認
1. markdownファイルを開く
2. `/` または `@` を入力
3. 補完候補が表示されるか確認

## トラブルシューティング

### プラグインがロードされない
```lua
-- runtimepathの確認
:echo &runtimepath

-- プラグインのパスが含まれているか確認
:lua print(vim.fn.expand('~/ghq/github.com/biosugar0/cmp-claudecode'))
```

### after/pluginが実行されない
dotfilesの設定で `lazy = false` を追加：
```lua
{
  dir = vim.fn.expand('~/ghq/github.com/biosugar0/cmp-claudecode'),
  dependencies = { 'hrsh7th/nvim-cmp', 'nvim-lua/plenary.nvim' },
  dev = true,
  lazy = false,  -- 重要！
}
```

### ソースが登録されない
```lua
-- 手動で登録してみる
:lua require('cmp').register_source('claude_slash', require('cmp_claudecode.slash'))
:lua require('cmp').register_source('claude_at', require('cmp_claudecode.at'))
```

### 補完が表示されない
```lua
-- is_available()の確認
:lua print(require('cmp_claudecode.slash'):is_available())
:lua print(require('cmp_claudecode.at'):is_available())

-- configの確認
:lua print(vim.inspect(require('cmp_claudecode.config').get()))

-- 現在のファイルタイプ確認
:echo &filetype
```

## デバッグログの有効化
```lua
-- 起動時に設定
vim.g.cmp_claudecode_debug = true

-- または dotfiles に追加
config = function()
  vim.g.cmp_claudecode_debug = true
  -- 他の設定...
end
```

## 開発時の推奨設定（dotfiles）
```lua
{
  dir = vim.fn.expand('~/ghq/github.com/biosugar0/cmp-claudecode'),
  dependencies = { 'hrsh7th/nvim-cmp', 'nvim-lua/plenary.nvim' },
  dev = true,   -- ローカル開発優先
  lazy = false, -- 即座にロード
  config = function()
    vim.g.cmp_claudecode_debug = true  -- デバッグ有効化
    -- カスタム設定が必要な場合のみ setup() を呼ぶ
  end,
}
```