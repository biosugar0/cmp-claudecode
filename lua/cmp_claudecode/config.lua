local M = {}

local defaults = {
  enabled = {
    filetypes = { 'markdown' },
    bufname_patterns = nil,
    custom = nil,
  },
  max_items = 200,
  scan_hidden = false,
  respect_gitignore = true,
  max_file_size = 1024 * 1024,
}

local config = vim.deepcopy(defaults)

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
end

function M.get()
  return config
end

function M.is_enabled()
  local cfg = config.enabled

  if cfg.custom then
    return cfg.custom()
  end

  if cfg.filetypes and #cfg.filetypes > 0 then
    local ft = vim.bo.filetype
    local ft_matched = false
    for _, allowed_ft in ipairs(cfg.filetypes) do
      if ft == allowed_ft then
        ft_matched = true
        break
      end
    end

    if not ft_matched then
      return false
    end

    if cfg.bufname_patterns and #cfg.bufname_patterns > 0 then
      local bufname = vim.fn.bufname()
      for _, pattern in ipairs(cfg.bufname_patterns) do
        if bufname:find(pattern) then
          return true
        end
      end
      return false
    else
      return true
    end
  end

  return false
end

return M
