-- lua/cmp_claudecode/at.lua
local scan = require('plenary.scandir')
local Path = require('plenary.path')
local util = require('cmp_claudecode.util')
local config = require('cmp_claudecode.config')

local M = {}

-- @だけでもトリガーされるようにkeyword_lengthを0に設定
function M:get_keyword_length()
  return 0
end

function M:is_available()
  local result = config.is_enabled()
  if vim.g.cmp_claudecode_debug then
    vim.notify('[cmp-claudecode.at] is_available: ' .. tostring(result), vim.log.levels.INFO)
  end
  return result
end

function M:get_trigger_characters()
  return {'@'}
end

function M:get_keyword_pattern()
  -- Vim正規表現：@を含めて、\zsで実際のキーワード開始位置を指定
  -- @の後の英数字、アンダースコア、スラッシュ、ドット、ハイフンを0文字以上
  -- 注意: *はエスケープしない（量指定子として使用）
  return [[@\zs\%(\k\|[\/_.-]\)*]]
end

function M:complete(params, cb)
  if vim.g.cmp_claudecode_debug then
    vim.notify('[cmp-claudecode.at] complete() called', vim.log.levels.INFO)
  end
  
  -- 現在の行のカーソル位置までのテキストを取得
  local line = params.context.cursor_before_line
  
  if vim.g.cmp_claudecode_debug then
    vim.notify('[cmp-claudecode.at] line: "' .. line .. '"', vim.log.levels.INFO)
  end
  
  -- @で始まっているか確認（@だけでもマッチするように修正）
  local has_at = line:match('@') ~= nil
  local at_pos = line:find('@[%w%.%-_/]*$')
  
  if vim.g.cmp_claudecode_debug then
    vim.notify('[cmp-claudecode.at] has_at: ' .. tostring(has_at) .. ', at_pos: ' .. tostring(at_pos), vim.log.levels.INFO)
  end
  
  if not at_pos then
    if vim.g.cmp_claudecode_debug then
      vim.notify('[cmp-claudecode.at] pattern not matched', vim.log.levels.INFO)
    end
    cb({})
    return
  end
  
  local items = {}
  local git_root = util.git_root()
  
  -- Git root配下のファイルを再帰的に探索
  local cfg = config.get()
  scan.scan_dir(git_root, {
    hidden = cfg.scan_hidden,
    add_dirs = true,
    respect_gitignore = cfg.respect_gitignore,
    on_insert = function(filepath)
      -- .gitディレクトリは除外
      if filepath:match('%.git[/\\]') then
        return
      end
      
      local stat = vim.loop.fs_stat(filepath)
      if not stat then return end
      
      -- 設定されたサイズ以上のファイルは除外
      if stat.type == 'file' and stat.size > cfg.max_file_size then
        return
      end
      
      local path = Path:new(filepath)
      local relative = path:make_relative(git_root)
      
      local item = {
        label = '@' .. relative,  -- @を含める（slashと同じ構造）
        insertText = '@' .. relative,
        kind = stat.type == 'directory' 
          and require('cmp').lsp.CompletionItemKind.Folder
          or require('cmp').lsp.CompletionItemKind.File,
        detail = stat.type == 'directory' and '' or util.format_size(stat.size),
        sortText = (stat.type == 'directory' and '0' or '1') .. relative:lower(),
        data = {
          filepath = filepath,
          is_dir = stat.type == 'directory'
        }
      }
      
      -- ディレクトリの場合は末尾に/を追加
      if stat.type == 'directory' then
        item.label = item.label .. '/'
        item.insertText = item.insertText .. '/'
      end
      
      table.insert(items, item)
      
      -- 設定された最大件数で打ち切り
      if #items >= cfg.max_items then
        return false  -- scan終了
      end
    end
  })
  
  if vim.g.cmp_claudecode_debug then
    vim.notify('[cmp-claudecode.at] Returning ' .. #items .. ' items', vim.log.levels.INFO)
  end
  cb(items)
end

function M:resolve(item, cb)
  -- ファイルの場合は先頭20行をドキュメントとして表示
  if item.data and item.data.filepath and not item.data.is_dir then
    local content = util.read_file_head(item.data.filepath, 20)
    if content then
      item.documentation = {
        kind = 'markdown',
        value = '```\n' .. content .. '\n```'
      }
    end
  end
  cb(item)
end

return M