# cmp-claudecode 設定ガイド

## 基本設定（ゼロコンフィグ）

プラグインはデフォルトで以下の条件で動作します：
- ファイルタイプ: `markdown`

## カスタム設定

`setup()` 関数を使用して、対象バッファをカスタマイズできます：

```lua
require('cmp_claudecode').setup({
  enabled = {
    -- ファイルタイプで指定
    filetypes = { 'terminal', 'markdown', 'gitcommit', 'text' },
    
    -- バッファ名のパターンで指定（vim.fn.bufname():find() で使用）
    bufname_patterns = { 'ClaudeCode', 'editprompt%-.*%.md' },
    
    -- カスタム関数での判定（より柔軟な制御が必要な場合）
    custom = function()
      -- 例: ファイル名が "prompt-" で始まる場合も有効化
      return vim.bo.filetype == 'terminal' or vim.fn.expand('%:t'):match('^prompt%-')
    end,
  },
  
  -- その他の設定
  max_items = 200,              -- 補完候補の最大数
  scan_hidden = false,          -- 隠しファイルをスキャンするか
  respect_gitignore = true,     -- .gitignore を尊重するか
  max_file_size = 1024 * 1024,  -- スキャンする最大ファイルサイズ（バイト）
})
```

## 設定例

### 1. 特定のプロジェクトでのみ有効化

```lua
require('cmp_claudecode').setup({
  enabled = {
    custom = function()
      local cwd = vim.fn.getcwd()
      return cwd:match('my%-ai%-project')
    end,
  },
})
```

### 2. 特定のバッファ名パターンで有効化

```lua
require('cmp_claudecode').setup({
  enabled = {
    filetypes = { 'terminal', 'markdown' },
    bufname_patterns = { 
      'ClaudeCode',           -- ClaudeCode ターミナル
      'ai%-prompt%-.*%.md',   -- AI プロンプトファイル
      'chat%-.*%.md',         -- チャットログ
    },
  },
})
```

### 3. ClaudeCode ターミナルで使用する

```lua
require('cmp_claudecode').setup({
  enabled = {
    filetypes = { 'terminal' },
    bufname_patterns = { 'ClaudeCode' },
  },
})
```

### 4. より大きなファイルも含める

```lua
require('cmp_claudecode').setup({
  max_file_size = 10 * 1024 * 1024,  -- 10MB まで
  max_items = 500,                    -- より多くの候補を表示
})
```

## nvim-cmp での使用

```lua
-- 特定のファイルタイプで有効化
cmp.setup.filetype({ 'markdown', 'gitcommit', 'text', 'terminal' }, {
  sources = cmp.config.sources({
    { name = 'claude_slash', priority = 1000 },  -- / コマンド補完
    { name = 'claude_at', priority = 1000 },     -- @ ファイル参照補完
    { name = 'path' },
    { name = 'buffer' },
  }),
})
```