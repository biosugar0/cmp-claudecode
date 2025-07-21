-- lua/cmp_claudecode/slash.lua
local uv = vim.loop
local scan = require('plenary.scandir')
local Path = require('plenary.path')
local util = require('cmp_claudecode.util')
local builtins = require('cmp_claudecode.builtins')
local config = require('cmp_claudecode.config')

local M = {}

-- /だけでもトリガーされるようにkeyword_lengthを0に設定
function M:get_keyword_length()
  return 0
end

function M:is_available()
  local result = config.is_enabled()
  if vim.g.cmp_claudecode_debug then
    vim.notify('[cmp-claudecode.slash] is_available: ' .. tostring(result), vim.log.levels.INFO)
  end
  return result
end

function M:get_trigger_characters()
  return {'/'}
end

function M:get_keyword_pattern()
  -- Vim正規表現：/を含めて、\zsで実際のキーワード開始位置を指定
  -- /の後の英数字、アンダースコア、ハイフン、コロンを0文字以上
  -- 注意: *はエスケープしない（量指定子として使用）
  return [[/\zs\%(\k\|[-:]\)*]]
end

function M:complete(params, cb)
  if vim.g.cmp_claudecode_debug then
    vim.notify('[cmp-claudecode.slash] complete() called', vim.log.levels.INFO)
  end
  
  -- 現在の行のカーソル位置までのテキストを取得
  local line = params.context.cursor_before_line
  
  -- @の後の/の場合は無視（ファイルパス補完中）
  if line:match('@[%w%.%-_/]*$') then
    cb({})
    return
  end
  
  -- /で始まっているか確認
  if not line:match('/[%w%-%:]*$') then
    cb({})
    return
  end
  
  local items = {}
  local seen = {}
  
  -- Built-in commands
  for _, cmd in ipairs(builtins) do
    table.insert(items, {
      label = '/' .. cmd,
      detail = '(built-in)',
      kind = require('cmp').lsp.CompletionItemKind.Keyword,
    })
    seen[cmd] = true
  end
  
  -- Custom commands
  local dirs = {
    vim.env.CLAUDE_CONFIG_DIR and (vim.env.CLAUDE_CONFIG_DIR .. '/commands'),
    vim.fn.expand('~/.claude/commands'),
    util.git_root() .. '/.claude/commands'
  }
  
  for i, dir in ipairs(dirs) do
    if dir and uv.fs_stat(dir) then
      local detail = i <= 2 and '(user)' or '(project)'
      
      scan.scan_dir(dir, {
        hidden = false,
        add_dirs = false,
        search_pattern = '%.md$',
        on_insert = function(filepath)
          local path = Path:new(filepath)
          local rel = path:make_relative(dir):gsub('%.md$', ''):gsub('[/\\]', ':')
          
          if not seen[rel] then
            -- メタデータ読み込み
            local content = util.read_file_head(filepath, 20)
            local frontmatter, body_line = util.parse_frontmatter(content or '')
            
            local item = {
              label = '/' .. rel,
              detail = detail,
              kind = require('cmp').lsp.CompletionItemKind.Keyword,
              sortText = detail == '(built-in)' and '0' .. rel or '1' .. rel,
            }
            
            -- documentation設定
            if frontmatter and frontmatter.description then
              item.documentation = {
                kind = 'markdown',
                value = frontmatter.description
              }
            elseif body_line ~= '' then
              item.documentation = body_line
            end
            
            -- snippetサポート（argument-hint）
            if frontmatter and frontmatter['argument-hint'] then
              item.insertText = '/' .. rel .. ' ' .. frontmatter['argument-hint']
              item.insertTextFormat = 2  -- Snippet
            end
            
            table.insert(items, item)
            seen[rel] = true
          end
        end
      })
    end
  end
  
  cb(items)
end

function M:resolve(item, cb)
  -- resolve時に詳細なドキュメントを設定
  cb(item)
end

return M