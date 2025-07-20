---@class cmp_claudecode.cache
local M = {}

local uv = vim.loop or vim.uv

---@class SimpleCache
---@field private capacity number Maximum number of entries
---@field private ttl number Time to live in milliseconds
---@field private entries table<string, {value: any, timestamp: number}>
---@field private order string[] Keys in LRU order
local SimpleCache = {}
SimpleCache.__index = SimpleCache

---Create a new simple LRU cache
---@param capacity number Maximum entries
---@param ttl number Time to live in milliseconds
---@return SimpleCache
function M.new(capacity, ttl)
	return setmetatable({
		capacity = capacity or 500,
		ttl = ttl or 60000,
		entries = {},
		order = {},
	}, SimpleCache)
end

---Move key to front (most recently used)
---@param key string
function SimpleCache:_touch(key)
	-- Remove from current position
	for i, k in ipairs(self.order) do
		if k == key then
			table.remove(self.order, i)
			break
		end
	end
	-- Add to front
	table.insert(self.order, 1, key)
end

---Evict least recently used entries
function SimpleCache:_evict()
	-- Remove expired entries
	local now = uv.now()
	local keys_to_remove = {}
	
	for key, entry in pairs(self.entries) do
		if now - entry.timestamp > self.ttl then
			table.insert(keys_to_remove, key)
		end
	end
	
	for _, key in ipairs(keys_to_remove) do
		self.entries[key] = nil
		for i, k in ipairs(self.order) do
			if k == key then
				table.remove(self.order, i)
				break
			end
		end
	end
	
	-- Remove oldest entries if over capacity
	while #self.order > self.capacity do
		local key = table.remove(self.order)
		if key then
			self.entries[key] = nil
		end
	end
end

---Get value from cache
---@param key string
---@return any|nil value, boolean is_hit
function SimpleCache:get(key)
	local entry = self.entries[key]
	if not entry then
		return nil, false
	end
	
	-- Check TTL
	if uv.now() - entry.timestamp > self.ttl then
		self.entries[key] = nil
		return nil, false
	end
	
	self:_touch(key)
	return entry.value, true
end

---Set value in cache
---@param key string
---@param value any
function SimpleCache:set(key, value)
	self.entries[key] = {
		value = value,
		timestamp = uv.now(),
	}
	self:_touch(key)
	self:_evict()
end

---Clear entire cache
function SimpleCache:clear()
	self.entries = {}
	self.order = {}
end

---Global cache instances with fixed configuration
M.file_cache = M.new(500, 60000) -- 1 minute TTL
M.command_cache = M.new(200, 300000) -- 5 minutes TTL

return M