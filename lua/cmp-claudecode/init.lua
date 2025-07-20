---@class cmp_claudecode
local M = {}

---@class cmp_claudecode.Source
---@field options table
local source = {}

local config = require('cmp-claudecode.config')
local utils = require('cmp-claudecode.utils')
local async = require('cmp-claudecode.async')

---Setup function to configure the plugin
---@param opts? table Custom configuration options
function M.setup(opts)
	if opts then
		config.defaults = vim.tbl_deep_extend('force', config.defaults, opts)
		if not config.validate(config.defaults) then
			vim.notify('[cmp-claudecode] Invalid configuration', vim.log.levels.ERROR)
		end
	end
end

---Create a new source instance
---@param opts? table Optional configuration
---@return cmp_claudecode.Source
source.new = function(opts)
	local self = setmetatable({}, { __index = source })
	-- nvim-cmpはsetup時にオプションを渡さないので、常にデフォルトを使用
	self.options = vim.tbl_deep_extend('force', config.defaults, opts or {})
	
	-- Create debounced complete function with fixed 50ms delay
	self._debounced_complete = async.debounce(function(params, callback)
		self:_do_complete(params, callback)
	end, 50)
	
	return self
end

---Check if the source is available
---@return boolean
function source:is_available()
	-- デフォルト: 常に有効（cmp.setup.filetype()で制御することを推奨）
	return true
end

---Get debug name for the source
---@return string
function source:get_debug_name()
	return 'claudecode'
end

---Get trigger characters
---@return string[]
function source:get_trigger_characters()
	return config.fixed.trigger_characters
end

---Get keyword pattern for completion matching
---@return string
function source:get_keyword_pattern()
	-- ファイルパス補完とスラッシュコマンドをサポート
	-- Vimの正規表現を使用（Luaの正規表現ではない）
	-- /で始まるコマンドまたは@で始まるパス（@単体でもマッチ）
	return [[\%(/[a-zA-Z0-9_:\-]*\|@[a-zA-Z0-9_./-]*\|@\)]]
end

---Complete function called by nvim-cmp
---@param params table Completion parameters from nvim-cmp
---@param callback function Callback to return completion items
function source:complete(params, callback)
	-- Initialize debounced function if not exists (for direct use without new())
	if not self._debounced_complete then
		self._debounced_complete = async.debounce(function(p, cb)
			self:_do_complete(p, cb)
		end, 50)
	end
	
	-- Always use debounced async version for better performance
	self._debounced_complete(params, callback)
end

---Internal complete implementation
---@param params table Completion parameters from nvim-cmp
---@param callback function Callback to return completion items
function source:_do_complete(params, callback)
	local context = params.context
	local line = context.cursor_line
	local col = context.cursor.col
	local before_cursor = context.cursor_before_line or line:sub(1, col - 1)
	
	-- オプションがない場合はデフォルトを使用
	local opts = self.options or config.defaults
	
	-- デバッグ出力
	if vim.g.cmp_claudecode_debug then
		vim.notify(string.format('[cmp-claudecode] complete: before_cursor="%s", col=%d', before_cursor, col), vim.log.levels.INFO)
	end
	
	-- @によるファイル参照の補完を優先（@単体でもマッチ）
	if before_cursor:match('@[%w%._%-/]*$') or before_cursor:match('@$') then
		if vim.g.cmp_claudecode_debug then
			vim.notify('[cmp-claudecode] Calling get_file_references', vim.log.levels.INFO)
		end
		utils.get_file_references(before_cursor, config.fixed, function(items)
			if vim.g.cmp_claudecode_debug then
				vim.notify(string.format('[cmp-claudecode] file references: found %d items', #items), vim.log.levels.INFO)
			end
			self:_send_results(items, opts, callback)
		end)
	-- /によるスラッシュコマンドの補完（行頭または空白の後のみ）
	elseif before_cursor:match('^/[%w_:-]*$') or before_cursor:match('%s/[%w_:-]*$') then
		utils.get_slash_commands(before_cursor, config.fixed, function(items)
			if vim.g.cmp_claudecode_debug then
				vim.notify(string.format('[cmp-claudecode] slash commands: found %d items', #items), vim.log.levels.INFO)
			end
			self:_send_results(items, opts, callback)
		end)
	else
		-- No matches
		callback({
			items = {},
			isIncomplete = false,
		})
	end
end

---Helper to send results with sorting and limits
---@param items table[] Completion items
---@param opts table Options
---@param callback function Callback function
function source:_send_results(items, opts, callback)
	-- ソート処理
	table.sort(items, function(a, b)
		return (a.sortText or a.label) < (b.sortText or b.label)
	end)
	
	-- 最大アイテム数で制限
	if #items > opts.max_items then
		items = vim.list_slice(items, 1, opts.max_items)
	end
	
	callback({
		items = items,
		isIncomplete = #items >= opts.max_items,
	})
end



-- Create a default instance for nvim-cmp
local default_instance = source.new()

-- Export module with source methods
M.new = source.new
M.complete = function(self, params, callback)
	-- If called as module method, use default instance
	if self == M then
		return default_instance:complete(params, callback)
	end
	-- Otherwise, use as instance method
	return source.complete(self, params, callback)
end

M.is_available = function(self)
	if self == M then
		return default_instance:is_available()
	end
	return source.is_available(self)
end

M.get_debug_name = function(self)
	if self == M then
		return default_instance:get_debug_name()
	end
	return source.get_debug_name(self)
end

M.get_trigger_characters = function(self)
	if self == M then
		return default_instance:get_trigger_characters()
	end
	return source.get_trigger_characters(self)
end

M.get_keyword_pattern = function(self)
	if self == M then
		return default_instance:get_keyword_pattern()
	end
	return source.get_keyword_pattern(self)
end

return M