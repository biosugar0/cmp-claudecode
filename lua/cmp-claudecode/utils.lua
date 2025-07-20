---@class cmp_claudecode.utils
local M = {}

local async = require('cmp-claudecode.async')
local cache = require('cmp-claudecode.cache')
local uv = vim.loop or vim.uv

-- Active async tasks for cancellation
local active_tasks = {}

-- Fixed constants
local MAX_DEPTH = 5

---Simple prefix/substring filter
---@param items table[] Items to filter
---@param pattern string Search pattern
---@param key_fn? fun(item: table): string Function to extract searchable text
---@return table[] Filtered items
local function filter_items(items, pattern, key_fn)
	if pattern == '' then
		return items
	end
	
	key_fn = key_fn or function(item)
		return item.name or item.label or ''
	end
	
	local pattern_lower = pattern:lower()
	local filtered = {}
	
	-- First pass: prefix matches
	for _, item in ipairs(items) do
		local text = key_fn(item):lower()
		if text:sub(1, #pattern) == pattern_lower then
			table.insert(filtered, item)
		end
	end
	
	-- Second pass: substring matches (if not already included)
	local included = {}
	for _, item in ipairs(filtered) do
		included[item] = true
	end
	
	for _, item in ipairs(items) do
		if not included[item] then
			local text = key_fn(item):lower()
			if text:find(pattern_lower, 1, true) then
				table.insert(filtered, item)
			end
		end
	end
	
	return filtered
end

---Generate file reference completion items
---@param before_cursor string Text before cursor
---@param options table Plugin options
---@param callback fun(items: table[]) Callback for async results
function M.get_file_references(before_cursor, options, callback)
	local at_pos = before_cursor:find('@[%w%._%-/]*$') or before_cursor:find('@$')
	if not at_pos then
		M.debug_print('No @ pattern found in: ' .. before_cursor)
		callback({})
		return
	end
	
	local prefix = before_cursor:sub(at_pos + 1) -- @を除いた部分
	M.debug_print(string.format('File ref: at_pos=%d, prefix="%s"', at_pos, prefix))
	local ok, cwd = pcall(vim.fn.getcwd)
	if not ok then
		M.debug_print('Failed to get current working directory')
		callback({})
		return
	end
	M.debug_print('Current working directory: ' .. cwd)
	
	local search_dir = cwd
	local search_pattern = prefix
	
	-- ディレクトリとパターンを分離
	local last_sep = prefix:find('[/\\][^/\\]*$')
	if last_sep then
		local dir_part = prefix:sub(1, last_sep - 1)
		local full_path = cwd .. '/' .. dir_part
		M.debug_print(string.format('Resolving path: %s', full_path))
		local ok_resolve, resolved = pcall(vim.fn.resolve, full_path)
		if ok_resolve then
			search_dir = resolved
			M.debug_print(string.format('Resolved to: %s', search_dir))
		else
			M.debug_print(string.format('Failed to resolve: %s', resolved))
		end
		search_pattern = prefix:sub(last_sep + 1)
	end
	
	M.debug_print(string.format('Search dir: %s, pattern: "%s"', search_dir, search_pattern))
	
	-- Check cache first
	local cache_key = string.format('files:%s:%s', search_dir, vim.inspect(options.file_reference))
	local cached_files, cache_hit = cache.file_cache:get(cache_key)
	
	-- Function to process files and create completion items
	local function process_files(files)
		local items = {}
		
		-- Filter files by pattern
		if search_pattern ~= '' then
			files = filter_items(files, search_pattern)
		end
		
		for _, file in ipairs(files) do
			local is_dir = file.type == 'directory'
			-- prefixがある場合はディレクトリパスを含む
			local file_path = prefix == '' and file.name or (prefix .. file.name)
			
			table.insert(items, {
				label = file.name .. (is_dir and '/' or ''),  -- 表示用（ファイル名のみ）
				insertText = '@' .. file_path .. (is_dir and '/' or ''),  -- 実際に挿入されるテキスト
				filterText = '@' .. file_path,  -- フィルタリング用
				kind = require('cmp').lsp.CompletionItemKind[is_dir and 'Folder' or 'File'],
				sortText = (is_dir and '0' or '1') .. file.name:lower(),
				data = {
					file_path = file.path,
					is_directory = is_dir,
				},
			})
		end
		
		return items
	end
	
	-- Use cached data if available
	if cache_hit and cached_files then
		M.debug_print(string.format('Using cached files: %d items', #cached_files))
		vim.schedule(function()
			local items = process_files(cached_files)
			M.debug_print(string.format('Processed %d items from cache', #items))
			callback(items)
		end)
		return
	end
	
	-- Cancel previous task if exists
	if active_tasks.file_scan then
		active_tasks.file_scan.cancel()
	end
	
	-- Start async scan with fixed parameters
	local scan_opts = vim.tbl_extend('force', options.file_reference or {}, {
		max_depth = MAX_DEPTH,
	})
	
	M.debug_print(string.format('Starting async scan with options: %s', vim.inspect(scan_opts)))
	
	local files = {}
	active_tasks.file_scan = async.scandir_async(
		search_dir,
		scan_opts,
		function(item)
			-- Incremental update
			table.insert(files, item)
			if #files == 1 then
				M.debug_print('First file found: ' .. item.name)
			end
		end,
		function(all_files)
			M.debug_print(string.format('Async scan completed: %d files found', #all_files))
			-- Cache the results
			cache.file_cache:set(cache_key, all_files)
			-- Process and callback
			local items = process_files(all_files)
			M.debug_print(string.format('Processed %d items', #items))
			callback(items)
			active_tasks.file_scan = nil
		end
	)
end

---Generate slash command completion items
---@param before_cursor string Text before cursor
---@param options table Plugin options
---@param callback fun(items: table[]) Callback for async results
function M.get_slash_commands(before_cursor, options, callback)
	local slash_pos = before_cursor:find('/[%w_:-]*$')
	if not slash_pos then
		callback({})
		return
	end
	
	local prefix = before_cursor:sub(slash_pos + 1) -- /を除いた部分
	
	-- Process function that filters and formats commands
	local function process_commands(all_commands)
		local items = {}
		
		-- Filter commands by prefix
		local filtered = filter_items(all_commands, prefix, function(cmd)
			return cmd.name
		end)
		
		for _, cmd in ipairs(filtered) do
			table.insert(items, {
				label = '/' .. cmd.name,
				insertText = '/' .. cmd.name .. (cmd.has_args and ' ' or ''),
				filterText = '/' .. cmd.name,
				kind = require('cmp').lsp.CompletionItemKind[cmd.is_custom and 'Function' or 'Keyword'],
				documentation = {
					kind = 'markdown',
					value = cmd.documentation or cmd.description or '',
				},
				sortText = cmd.sort_text or ((cmd.is_custom and '1' or '0') .. cmd.name),
			})
		end
		
		return items
	end
	
	-- Get builtin commands (these don't change, so we can process them immediately)
	local all_commands = {}
	local builtin_commands = options.builtin_slash_commands or {}
	for _, cmd in ipairs(builtin_commands) do
		table.insert(all_commands, {
			name = cmd.name,
			has_args = cmd.has_args,
			description = cmd.description,
			is_custom = false,
		})
	end
	
	-- Function to scan custom commands (sync for now, will be made async)
	local function scan_commands_sync(dir, scope)
		local commands = {}
		local ok_isdir, is_dir = pcall(vim.fn.isdirectory, dir)
		if not ok_isdir or is_dir ~= 1 then
			return commands
		end
		
		-- Recursive scan function
		local function scan_recursive(base_dir, rel_path)
			local current_dir = rel_path == '' and base_dir or (base_dir .. '/' .. rel_path)
			local ok_handle, handle = pcall(uv.fs_scandir, current_dir)
			
			if ok_handle and handle then
				local ok_next, name, type = pcall(uv.fs_scandir_next, handle)
				while ok_next and name do
					local full_path = current_dir .. '/' .. name
					local new_rel_path = rel_path == '' and name or (rel_path .. '/' .. name)
					
					if type == 'directory' then
						-- Recursively scan subdirectories
						scan_recursive(base_dir, new_rel_path)
					elseif name:match('%.md$') then
						-- Process .md files as commands
						local cmd_name = name:sub(1, -4) -- Remove .md
						local namespace = rel_path:gsub('/', ':')
						local full_cmd_name = namespace == '' and cmd_name or (namespace .. ':' .. cmd_name)
						
						-- Read file metadata (cached)
						local metadata_cache_key = 'cmd_meta:' .. full_path
						local metadata, cache_hit = cache.command_cache:get(metadata_cache_key)
						
						if not cache_hit then
							metadata = {
								description = '',
								argument_hint = '',
							}
							
							local ok_read, file_content = pcall(vim.fn.readfile, full_path, '', 10)
							if ok_read and file_content then
								-- Parse YAML frontmatter
								local in_frontmatter = false
								for i, line in ipairs(file_content) do
									if i == 1 and line == '---' then
										in_frontmatter = true
									elseif in_frontmatter and line == '---' then
										break
									elseif in_frontmatter then
										if line:match('^description:%s*(.+)') then
											metadata.description = line:match('^description:%s*(.+)')
										elseif line:match('^argument%-hint:%s*(.+)') then
											metadata.argument_hint = line:match('^argument%-hint:%s*(.+)')
										end
									end
								end
								
								-- Fallback to first non-empty line
								if metadata.description == '' then
									for _, line in ipairs(file_content) do
										if line ~= '' and not line:match('^#') and not line:match('^%-%-%-') then
											metadata.description = line
											break
										end
									end
								end
							end
							
							-- Cache the metadata
							cache.command_cache:set(metadata_cache_key, metadata)
						end
						
						table.insert(commands, {
							name = full_cmd_name,
							has_args = true,
							description = metadata.description,
							documentation = string.format(
								'**%s command** (%s)\n\n%s%s',
								scope == 'user' and 'Personal' or 'Project',
								scope,
								metadata.description,
								metadata.argument_hint ~= '' and '\n\n**Arguments**: ' .. metadata.argument_hint or ''
							),
							is_custom = true,
							sort_text = '1' .. full_cmd_name,
						})
					end
					
					ok_next, name, type = pcall(uv.fs_scandir_next, handle)
				end
			end
		end
		
		scan_recursive(dir, '')
		return commands
	end

	-- Helper function to get custom command directories
	local function get_command_dirs()
		local dirs = {}
		
		-- Project commands directory
		local project_root = nil
		local ok_git, git_root = pcall(vim.fn.system, 'git rev-parse --show-toplevel 2>/dev/null')
		if ok_git and vim.v.shell_error == 0 then
			project_root = vim.trim(git_root)
		else
			local ok_cwd, cwd = pcall(vim.fn.getcwd)
			if ok_cwd then
				project_root = cwd
			end
		end
		
		if project_root then
			table.insert(dirs, {
				path = project_root .. '/.claude/commands',
				scope = 'project',
			})
		end
		
		-- User commands directory
		local claude_config_dir = vim.fn.getenv('CLAUDE_CONFIG_DIR')
		if claude_config_dir ~= vim.NIL and claude_config_dir ~= '' then
			table.insert(dirs, {
				path = vim.fn.expand(claude_config_dir .. '/commands'),
				scope = 'user',
			})
		else
			table.insert(dirs, {
				path = vim.fn.expand('~/.claude/commands'),
				scope = 'user',
			})
		end
		
		return dirs
	end
	
	-- Check cache for custom commands
	local dirs = get_command_dirs()
	local cache_key = 'custom_commands:' .. vim.inspect(dirs)
	local cached_commands, cache_hit = cache.command_cache:get(cache_key)
	
	if cache_hit and cached_commands then
		-- Combine with builtin commands and return
		for _, cmd in ipairs(cached_commands) do
			table.insert(all_commands, cmd)
		end
		vim.schedule(function()
			callback(process_commands(all_commands))
		end)
		return
	end
	
	-- Scan custom commands asynchronously
	vim.schedule(function()
		local custom_commands = {}
		for _, dir_info in ipairs(dirs) do
			M.debug_print('Checking commands dir: ' .. dir_info.path)
			local cmds = scan_commands_sync(dir_info.path, dir_info.scope)
			for _, cmd in ipairs(cmds) do
				table.insert(custom_commands, cmd)
			end
		end
		
		-- Cache the custom commands
		cache.command_cache:set(cache_key, custom_commands)
		
		-- Combine with builtin commands
		for _, cmd in ipairs(custom_commands) do
			table.insert(all_commands, cmd)
		end
		
		callback(process_commands(all_commands))
	end)
end

-- デバッグ用ユーティリティ
function M.debug_print(msg)
	if vim.g.cmp_claudecode_debug then
		vim.notify('[cmp-claudecode] ' .. vim.inspect(msg), vim.log.levels.INFO)
	end
end

return M