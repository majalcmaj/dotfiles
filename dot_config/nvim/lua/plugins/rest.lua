return {
	"rest-nvim/rest.nvim",
	ft = { "http" },
	-- rest.nvim needs the `http` tree-sitter parser at runtime.
	-- It is built (plugin-free) via `:TSBuild http` — see lua/treesitter.lua.
	config = function()
		vim.g.rest_nvim = {
			_log_level = vim.log.levels.DEBUG,
		}
	end,
}
