-- lua/cmp_claudecode/at.lua
local Path = require('plenary.path')
local util = require('cmp_claudecode.util')
local config = require('cmp_claudecode.config')

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

-- @だけでもトリガーされるようにkeyword_lengthを0に設定
function source:get_keyword_length()
  return 0
end

function source:is_available()
  return config.is_enabled()
end

function source:get_trigger_characters()
  return {'@'}
end

function source:get_keyword_pattern()
  -- Vim正規表現：@を含めて、\zsで実際のキーワード開始位置を指定
  -- @の後の英数字、アンダースコア、スラッシュ、ドット、ハイフンを0文字以上
  -- 注意: *はエスケープしない（量指定子として使用）
  return [[@\zs\%(\k\|[\/_.-]\)*]]
end

function source:complete(params, cb)
  -- 現在の行のカーソル位置までのテキストを取得
  local line = params.context.cursor_before_line
  
  -- @で始まっているか確認（@だけでもマッチするように修正）
  local has_at = line:match('@') ~= nil
  local at_pos = line:find('@[%w%.%-_/]*$')
  
  if not at_pos then
    cb({})
    return
  end
  
  local items = {}
  local git_root = util.git_root()
  local cfg = config.get()
  
  -- Git root配下のファイルを再帰的に探索
  util.scan_git_root(function(filepath, stat)
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
  end)
  
  cb(items)
end

function source:resolve(item, cb)
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

return source