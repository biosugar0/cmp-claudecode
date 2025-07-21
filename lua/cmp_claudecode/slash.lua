local uv = vim.loop
local scan = require('plenary.scandir')
local Path = require('plenary.path')
local util = require('cmp_claudecode.util')
local builtins = require('cmp_claudecode.builtins')
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
  return { '/' }
end

function source:get_keyword_pattern()
  return [[/\zs\%(\k\|[-:]\)*]]
end

function source:complete(params, cb)
  local line = params.context.cursor_before_line

  if line:match('@[%w%.%-_/]*$') then
    cb({})
    return
  end

  if not line:match('/[%w%-%:]*$') then
    cb({})
    return
  end

  local items = {}
  local seen = {}

  for _, cmd in ipairs(builtins) do
    table.insert(items, {
      label = '/' .. cmd,
      detail = '(built-in)',
      kind = require('cmp').lsp.CompletionItemKind.Keyword,
    })
    seen[cmd] = true
  end

  local dirs = {
    vim.env.CLAUDE_CONFIG_DIR and (vim.env.CLAUDE_CONFIG_DIR .. '/commands'),
    vim.fn.expand('~/.claude/commands'),
    util.git_root() .. '/.claude/commands',
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
            local content = util.read_file_head(filepath, 20)
            local frontmatter, body_line = util.parse_frontmatter(content or '')

            local item = {
              label = '/' .. rel,
              detail = detail,
              kind = require('cmp').lsp.CompletionItemKind.Keyword,
              sortText = detail == '(built-in)' and '0' .. rel or '1' .. rel,
            }

            if frontmatter and frontmatter.description then
              item.documentation = {
                kind = 'markdown',
                value = frontmatter.description,
              }
            elseif body_line ~= '' then
              item.documentation = body_line
            end

            if frontmatter and frontmatter['argument-hint'] then
              item.insertText = '/' .. rel .. ' ' .. frontmatter['argument-hint']
              item.insertTextFormat = 2 -- Snippet
            end

            table.insert(items, item)
            seen[rel] = true
          end
        end,
      })
    end
  end

  cb(items)
end

function source:resolve(item, cb)
  cb(item)
end

return source
