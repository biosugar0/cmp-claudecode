---Performance tests for cmp-claudecode
describe('cmp-claudecode performance', function()
	local source
	local cache = require('cmp-claudecode.cache')
	local async = require('cmp-claudecode.async')
	local uv = vim.loop or vim.uv
	
	before_each(function()
		-- Clear caches
		cache.file_cache:clear()
		cache.command_cache:clear()
		
		-- Reset configuration
		package.loaded['cmp-claudecode'] = nil
		package.loaded['cmp-claudecode.config'] = nil
		package.loaded['cmp-claudecode.utils'] = nil
		package.loaded['cmp-claudecode.async'] = nil
		package.loaded['cmp-claudecode.cache'] = nil
		
		-- Load the module
		local cmp_claudecode = require('cmp-claudecode')
		source = cmp_claudecode.new()
	end)
	
	describe('cache performance', function()
		it('should cache file scan results', function()
			-- Create test directory structure
			vim.fn.mkdir('test_cache_files/subdir', 'p')
			for i = 1, 100 do
				vim.fn.writefile({ 'test' }, string.format('test_cache_files/file%d.txt', i))
			end
			
			-- First call - no cache
			local start_time = uv.hrtime()
			local params = {
				context = {
					cursor_line = '@test_cache_files/',
					cursor = { row = 1, col = 19 }
				}
			}
			
			local items1
			source:complete(params, function(response)
				items1 = response.items
			end)
			
			-- Wait for async completion
			vim.wait(100)
			local first_duration = (uv.hrtime() - start_time) / 1e6 -- Convert to ms
			
			-- Second call - should use cache
			start_time = uv.hrtime()
			local items2
			source:complete(params, function(response)
				items2 = response.items
			end)
			
			vim.wait(10) -- Should be much faster
			local second_duration = (uv.hrtime() - start_time) / 1e6
			
			-- Verify cache is working
			assert.is_true(second_duration < first_duration / 2)
			assert.equals(#items1, #items2)
			
			-- Cleanup
			vim.fn.delete('test_cache_files', 'rf')
		end)
		
		it('should respect cache TTL', function()
			local test_cache = cache.new(10, 100) -- capacity 10, 100ms TTL
			
			test_cache:set('test_key', 'test_value')
			local value, hit = test_cache:get('test_key')
			assert.equals('test_value', value)
			assert.is_true(hit)
			
			-- Wait for TTL to expire
			vim.wait(150)
			
			value, hit = test_cache:get('test_key')
			assert.is_nil(value)
			assert.is_false(hit)
		end)
	end)
	
	describe('async performance', function()
		it('should handle large directory structures efficiently', function(done)
			-- Create large test structure
			vim.fn.mkdir('test_async_files', 'p')
			for i = 1, 10 do
				vim.fn.mkdir(string.format('test_async_files/dir%d', i), 'p')
				for j = 1, 50 do
					vim.fn.writefile({ 'test' }, string.format('test_async_files/dir%d/file%d.txt', i, j))
				end
			end
			
			local start_time = uv.hrtime()
			local params = {
				context = {
					cursor_line = '@test_async_files/',
					cursor = { row = 1, col = 19 }
				}
			}
			
			source:complete(params, vim.schedule_wrap(function(response)
				local duration = (uv.hrtime() - start_time) / 1e6
				
				-- Should complete within reasonable time
				assert.is_true(duration < 500) -- 500ms max
				assert.is_true(#response.items > 0)
				
				-- Cleanup
				vim.fn.delete('test_async_files', 'rf')
				
				done()
			end))
		end)
	end)
	
	describe('debouncing', function()
		it('should debounce rapid calls', function()
			local call_count = 0
			local debounced = async.debounce(function()
				call_count = call_count + 1
			end, 50)
			
			-- Make multiple rapid calls
			for i = 1, 10 do
				debounced()
			end
			
			-- Should not have been called yet
			assert.equals(0, call_count)
			
			-- Wait for debounce delay
			vim.wait(100)
			
			-- Should have been called only once
			assert.equals(1, call_count)
		end)
	end)
	
	
end)