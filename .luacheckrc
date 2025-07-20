-- vim: ft=lua tw=80

stds.nvim = {
	globals = {
		vim = { fields = { "g", "b", "w", "o", "bo", "wo", "go", "env" } },
		"jit",
	},
	read_globals = {
		"vim",
		-- Neovim lua API
		"describe",
		"it",
		"before_each",
		"after_each",
		"pending",
		"clear",
		"assert",
		-- Plenary busted
		"async",
		"a",
	},
}

std = "lua51+nvim"

files["test/*_spec.lua"] = {
	std = "lua51+nvim+busted",
}

-- Ignore max line length in tests
files["test/*_spec.lua"].ignore = { "631" }

-- Global ignores
ignore = {
	"212", -- Unused argument
	"631", -- Line is too long
}

-- Don't report unused self argument
self = false

-- Don't report on unused variable starting with _
unused_args = false

max_line_length = 120

cache = true