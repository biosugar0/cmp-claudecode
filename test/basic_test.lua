-- Basic test without Plenary dependency
local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✓ " .. name)
	else
		print("✗ " .. name)
		print("  Error: " .. tostring(err))
		os.exit(1)
	end
end

-- Add plugin to runtimepath
local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h')
vim.opt.runtimepath:prepend(plugin_dir)

-- Basic tests
print("Running basic tests for cmp-claudecode...\n")

test("Module can be loaded", function()
	require('cmp-claudecode')
end)

test("Setup function exists", function()
	local cmp_claudecode = require('cmp-claudecode')
	assert(type(cmp_claudecode.setup) == 'function', "setup should be a function")
end)

test("Can create source instance", function()
	local cmp_claudecode = require('cmp-claudecode')
	local source = cmp_claudecode.new()
	assert(source ~= nil, "source should not be nil")
end)

test("Source has required methods", function()
	local cmp_claudecode = require('cmp-claudecode')
	local source = cmp_claudecode.new()
	
	assert(type(source.is_available) == 'function', "is_available should be a function")
	assert(type(source.get_debug_name) == 'function', "get_debug_name should be a function")
	assert(type(source.get_trigger_characters) == 'function', "get_trigger_characters should be a function")
	assert(type(source.get_keyword_pattern) == 'function', "get_keyword_pattern should be a function")
	assert(type(source.complete) == 'function', "complete should be a function")
end)

test("Source is available", function()
	local cmp_claudecode = require('cmp-claudecode')
	local source = cmp_claudecode.new()
	assert(source:is_available() == true, "source should be available")
end)

test("Debug name is correct", function()
	local cmp_claudecode = require('cmp-claudecode')
	local source = cmp_claudecode.new()
	assert(source:get_debug_name() == 'claudecode', "debug name should be 'claudecode'")
end)

test("Trigger characters include / and @", function()
	local cmp_claudecode = require('cmp-claudecode')
	local source = cmp_claudecode.new()
	local triggers = source:get_trigger_characters()
	
	assert(type(triggers) == 'table', "trigger characters should be a table")
	assert(vim.tbl_contains(triggers, '/'), "trigger characters should include '/'")
	assert(vim.tbl_contains(triggers, '@'), "trigger characters should include '@'")
	assert(#triggers == 2, "should only have 2 trigger characters")
end)

test("Configuration validation works", function()
	local config = require('cmp-claudecode.config')
	local valid = config.validate(config.defaults)
	assert(valid == true, "default configuration should be valid")
end)

print("\nAll tests passed! ✨")