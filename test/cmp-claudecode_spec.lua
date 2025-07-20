describe('cmp-claudecode', function()
	local source
	
	before_each(function()
		-- Clear any existing source
		source = nil
		
		-- Reset configuration
		package.loaded['cmp-claudecode'] = nil
		package.loaded['cmp-claudecode.config'] = nil
		package.loaded['cmp-claudecode.utils'] = nil
		
		-- Load the module
		local cmp_claudecode = require('cmp-claudecode')
		source = cmp_claudecode.new()
	end)
	
	describe('setup', function()
		it('should accept custom configuration', function()
			local cmp_claudecode = require('cmp-claudecode')
			cmp_claudecode.setup({
				max_items = 100,
			})
			
			local config = require('cmp-claudecode.config')
			assert.equals(100, config.defaults.max_items)
		end)
	end)
	
	describe('source', function()
		it('should be available', function()
			assert.is_true(source:is_available())
		end)
		
		it('should return debug name', function()
			assert.equals('claudecode', source:get_debug_name())
		end)
		
		it('should return fixed trigger characters', function()
			local triggers = source:get_trigger_characters()
			assert.is_table(triggers)
			assert.is_true(vim.tbl_contains(triggers, '/'))
			assert.is_true(vim.tbl_contains(triggers, '@'))
		end)
		
		it('should return keyword pattern', function()
			local pattern = source:get_keyword_pattern()
			assert.is_string(pattern)
			assert.is_not_nil(pattern:find('@'))
		end)
	end)
	
	describe('complete', function()
		it('should complete slash commands', function(done)
			local params = {
				context = {
					cursor_line = 'Type /',
					cursor = { row = 1, col = 7 }
				}
			}
			
			source:complete(params, function(response)
				assert.is_table(response)
				assert.is_table(response.items)
				assert.is_true(#response.items > 0)
				
				-- Check if /help command exists
				local has_help = false
				for _, item in ipairs(response.items) do
					if item.label == '/help' then
						has_help = true
						break
					end
				end
				assert.is_true(has_help)
				
				done()
			end)
		end)
		
		it('should complete file references', function(done)
			-- Create a mock file structure
			vim.fn.mkdir('test_files', 'p')
			vim.fn.writefile({ 'test' }, 'test_files/test.md')
			
			local params = {
				context = {
					cursor_line = 'See @test_files/',
					cursor = { row = 1, col = 17 }
				}
			}
			
			source:complete(params, vim.schedule_wrap(function(response)
				assert.is_table(response)
				assert.is_table(response.items)
				
				-- Cleanup
				vim.fn.delete('test_files', 'rf')
				
				done()
			end))
		end)
	end)
	
end)