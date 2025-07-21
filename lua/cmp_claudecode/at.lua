local Path = require('plenary.path')
local util = require('cmp_claudecode.util')
local config = require('cmp_claudecode.config')

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_keyword_length()
  return 0
end

function source:is_available()
  return config.is_enabled()
end

function source:get_trigger_characters()
  return { '@' }
end

function source:get_keyword_pattern()
  return [[@\zs\%(\k\|[\/_.-]\)*]]
end

function source:complete(params, cb)
  local line = params.context.cursor_before_line

  local at_pos = line:find('@[%w%.%-_/]*$')

  if not at_pos then
    cb({})
    return
  end

  local items = {}
  local git_root = util.git_root()
  local cfg = config.get()

  util.scan_git_root(function(filepath, stat)
    local path = Path:new(filepath)
    local relative = path:make_relative(git_root)

    local item = {
      label = '@' .. relative,
      insertText = '@' .. relative,
      kind = stat.type == 'directory' and require('cmp').lsp.CompletionItemKind.Folder
        or require('cmp').lsp.CompletionItemKind.File,
      detail = stat.type == 'directory' and '' or util.format_size(stat.size),
      sortText = (stat.type == 'directory' and '0' or '1') .. relative:lower(),
      data = {
        filepath = filepath,
        is_dir = stat.type == 'directory',
      },
    }

    if stat.type == 'directory' then
      item.label = item.label .. '/'
      item.insertText = item.insertText .. '/'
    end

    table.insert(items, item)

    if #items >= cfg.max_items then
      return false
    end
  end)

  cb(items)
end

function source:resolve(item, cb)
  if item.data and item.data.filepath and not item.data.is_dir then
    local content = util.read_file_head(item.data.filepath, 20)
    if content then
      item.documentation = {
        kind = 'markdown',
        value = '```\n' .. content .. '\n```',
      }
    end
  end
  cb(item)
end

return source
