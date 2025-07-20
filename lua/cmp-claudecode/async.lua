---@class cmp_claudecode.async
local M = {}

local uv = vim.loop or vim.uv

---@class AsyncTask
---@field cancel fun()

---Scan directory asynchronously
---@param directory string Directory to scan
---@param opts table Options (exclude_patterns, show_hidden, max_depth)
---@param on_item fun(item: table) Called for each item found
---@param on_complete fun(items: table[]) Called when scan is complete
---@return AsyncTask
function M.scandir_async(directory, opts, on_item, on_complete)
	local cancelled = false
	local items = {}
	local pending = 1  -- Start with 1 to prevent early completion
	
	local function process_complete()
		if pending == 0 and not cancelled then
			vim.schedule(function()
				on_complete(items)
			end)
		end
	end
	
	local function scan_recursive(dir, depth)
		if cancelled or depth > opts.max_depth then
			return
		end
		
		pending = pending + 1
		
		-- Schedule the scan to run asynchronously
		vim.schedule(function()
			if cancelled then
				pending = pending - 1
				process_complete()
				return
			end
			
			-- fs_scandir is synchronous in vim.loop
			local ok, handle = pcall(uv.fs_scandir, dir)
			if not ok or not handle then
				pending = pending - 1
				process_complete()
				return
			end
			
			-- Process all entries in this directory
			while true do
				local ok_next, name, type = pcall(uv.fs_scandir_next, handle)
				if not ok_next or not name then
					break
				end
				
				-- Check exclusions
				local excluded = false
				for _, pattern in ipairs(opts.exclude_patterns or {}) do
					if name:match(pattern) then
						excluded = true
						break
					end
				end
				
				if not opts.show_hidden and name:match('^%.') then
					excluded = true
				end
				
				if not excluded and not cancelled then
					local item = {
						name = name,
						type = type,
						path = dir .. '/' .. name,
						depth = depth,
					}
					
					table.insert(items, item)
					
					-- Callback for incremental updates
					if on_item then
						vim.schedule(function()
							if not cancelled then
								on_item(item)
							end
						end)
					end
					
					-- Recursively scan subdirectories
					if type == 'directory' and depth < opts.max_depth then
						scan_recursive(item.path, depth + 1)
					end
				end
			end
			
			pending = pending - 1
			process_complete()
		end)
	end
	
	-- Start scanning
	scan_recursive(directory, 0)
	
	-- Decrement initial pending count
	pending = pending - 1
	process_complete()
	
	-- Return task handle
	return {
		cancel = function()
			cancelled = true
		end,
	}
end

---Create a debounced function
---@param fn function The function to debounce
---@param delay number Delay in milliseconds
---@return function Debounced function
function M.debounce(fn, delay)
	local timer = nil
	
	return function(...)
		local args = { ... }
		
		if timer then
			timer:stop()
			timer:close()
		end
		
		timer = uv.new_timer()
		timer:start(delay, 0, vim.schedule_wrap(function()
			timer:stop()
			timer:close()
			timer = nil
			fn(unpack(args))
		end))
	end
end

return M