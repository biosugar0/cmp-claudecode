-- lua/cmp_claudecode/util.lua
local util = {}

function util.git_root()
  local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1] or ''
  return root ~= '' and root or vim.loop.cwd()
end

-- YAMLフロントマター解析
function util.parse_frontmatter(content)
  local lines = vim.split(content, '\n')
  if #lines == 0 or lines[1] ~= '---' then
    return nil, lines[1] or ''
  end
  
  local yaml = {}
  local i = 2
  while i <= #lines and lines[i] ~= '---' do
    local key, value = lines[i]:match('^(%w+):%s*(.*)$')
    if key and value then
      yaml[key] = value
    end
    i = i + 1
  end
  
  -- 本文の最初の行を取得
  local body_line = lines[i + 1] or ''
  
  return yaml, body_line
end

-- ファイルの先頭N行を読み込む
function util.read_file_head(path, n)
  local file = io.open(path, 'r')
  if not file then return nil end
  
  local lines = {}
  for i = 1, n do
    local line = file:read('*l')
    if not line then break end
    table.insert(lines, line)
  end
  file:close()
  
  return table.concat(lines, '\n')
end

-- ファイルサイズを人間が読みやすい形式に
function util.format_size(size)
  if size < 1024 then
    return string.format('%d B', size)
  elseif size < 1024 * 1024 then
    return string.format('%.1f KB', size / 1024)
  else
    return string.format('%.1f MB', size / (1024 * 1024))
  end
end

return util