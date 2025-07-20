-- Test runner script
local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h')

-- Add plugin to runtimepath
vim.opt.runtimepath:prepend(plugin_dir)

-- Ensure test dependencies are installed
local test_dir = '/tmp/nvim-test-deps'
vim.fn.mkdir(test_dir, 'p')

local function ensure_installed(repo, name)
	local install_path = test_dir .. '/' .. name
	if vim.fn.isdirectory(install_path) == 0 then
		print('Installing ' .. name .. '...')
		vim.fn.system({
			'git', 'clone', '--depth=1',
			'https://github.com/' .. repo,
			install_path
		})
	end
	vim.opt.runtimepath:append(install_path)
end

-- Install dependencies
ensure_installed('nvim-lua/plenary.nvim', 'plenary.nvim')
ensure_installed('hrsh7th/nvim-cmp', 'nvim-cmp')

-- Run tests
require('plenary.test_harness').test_directory(
	plugin_dir .. '/test/',
	{
		minimal_init = plugin_dir .. '/test/minimal_init.lua',
		sequential = true,
	}
)