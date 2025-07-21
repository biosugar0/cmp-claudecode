-- lua/cmp_claudecode/config.lua
-- グローバル設定管理
local M = {}

-- デフォルト設定
local defaults = {
  -- 有効にするバッファの条件
  enabled = {
    -- ファイルタイプで指定
    filetypes = { 'markdown' },
    -- バッファ名のパターンで指定（vim.fn.bufname():find()で使用）
    bufname_patterns = nil,
    -- カスタム関数で指定（trueを返すと有効）
    custom = nil,
  },
  -- その他の設定
  max_items = 200,
  scan_hidden = false,
  respect_gitignore = true,
  max_file_size = 1024 * 1024, -- 1MB
}

-- 現在の設定
local config = vim.deepcopy(defaults)

-- 設定をセットアップ
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
end

-- 設定を取得
function M.get()
  return config
end

-- 現在のバッファで有効かチェック
function M.is_enabled()
  local cfg = config.enabled
  
  -- カスタム関数が定義されていればそれを使用
  if cfg.custom then
    return cfg.custom()
  end
  
  -- ファイルタイプチェック
  if cfg.filetypes and #cfg.filetypes > 0 then
    local ft = vim.bo.filetype
    local ft_matched = false
    for _, allowed_ft in ipairs(cfg.filetypes) do
      if ft == allowed_ft then
        ft_matched = true
        break
      end
    end
    
    if not ft_matched then
      return false
    end
    
    -- バッファ名パターンチェック（指定されている場合のみ）
    if cfg.bufname_patterns and #cfg.bufname_patterns > 0 then
      local bufname = vim.fn.bufname()
      for _, pattern in ipairs(cfg.bufname_patterns) do
        if bufname:find(pattern) then
          return true
        end
      end
      return false  -- ファイルタイプは一致したがバッファ名パターンが一致しない
    else
      -- バッファ名パターンが指定されていない場合はファイルタイプのみで判定
      return true
    end
  end
  
  return false
end

return M