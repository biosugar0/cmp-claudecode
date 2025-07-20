-- Minimal init for tests
vim.cmd [[set runtimepath=$VIMRUNTIME]]
vim.cmd [[set packpath=/tmp/nvim-test-site]]

-- Add current plugin to runtimepath
local plugin_dir = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('<sfile>:p')), ':h:h')
vim.opt.runtimepath:prepend(plugin_dir)

-- Install plenary.nvim for testing
local install_path = '/tmp/nvim-test-site/pack/vendor/start/plenary.nvim'
if vim.fn.isdirectory(install_path) == 0 then
	vim.fn.system({
		'git',
		'clone',
		'--depth=1',
		'https://github.com/nvim-lua/plenary.nvim',
		install_path
	})
end

-- Install nvim-cmp for testing
local cmp_install_path = '/tmp/nvim-test-site/pack/vendor/start/nvim-cmp'
if vim.fn.isdirectory(cmp_install_path) == 0 then
	vim.fn.system({
		'git',
		'clone',
		'--depth=1',
		'https://github.com/hrsh7th/nvim-cmp',
		cmp_install_path
	})
end

-- Add to runtimepath
vim.opt.runtimepath:append(install_path)
vim.opt.runtimepath:append(cmp_install_path)

-- Basic settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false