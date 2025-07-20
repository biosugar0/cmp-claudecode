local M = {}

M.defaults = {
	-- 唯一のカスタマイズ可能な設定
	max_items = 50,
}

-- 固定設定（内部使用）
M.fixed = {
	trigger_characters = { '/', '@' },
	file_reference = {
		show_hidden = false,
		exclude_patterns = { '%.git/', 'node_modules/', '%.DS_Store' },
	},
	builtin_slash_commands = {
		{ name = 'add-dir', description = 'Add additional working directories', has_args = true },
		{ name = 'bug', description = 'Report bugs (sends conversation to Anthropic)', has_args = true },
		{ name = 'clear', description = 'Clear conversation history', has_args = false },
		{ name = 'compact', description = 'Compact conversation with optional focus instructions', has_args = true },
		{ name = 'config', description = 'View/modify configuration', has_args = false },
		{ name = 'cost', description = 'Show token usage statistics', has_args = false },
		{ name = 'doctor', description = 'Checks the health of your Claude Code installation', has_args = false },
		{ name = 'help', description = 'Get usage help', has_args = false },
		{ name = 'init', description = 'Initialize project with CLAUDE.md guide', has_args = false },
		{ name = 'login', description = 'Switch Anthropic accounts', has_args = false },
		{ name = 'logout', description = 'Sign out from your Anthropic account', has_args = false },
		{ name = 'mcp', description = 'Manage MCP server connections and OAuth authentication', has_args = true },
		{ name = 'memory', description = 'Edit CLAUDE.md memory files', has_args = false },
		{ name = 'model', description = 'Select or change the AI model', has_args = true },
		{ name = 'permissions', description = 'View or update permissions', has_args = false },
		{ name = 'pr_comments', description = 'View pull request comments', has_args = false },
		{ name = 'review', description = 'Request code review', has_args = false },
		{ name = 'status', description = 'View account and system statuses', has_args = false },
		{ name = 'terminal-setup', description = 'Install Shift+Enter key binding for newlines', has_args = false },
		{ name = 'vim', description = 'Enter vim mode for alternating insert and command modes', has_args = false },
	},
}

-- 設定のバリデーション
function M.validate(opts)
	vim.validate({
		max_items = { opts.max_items, 'number', true },
	})
	return true
end

return M