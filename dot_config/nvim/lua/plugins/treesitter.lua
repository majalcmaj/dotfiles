return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
			"python",
			"go",
			"javascript",
			"typescript",
			"json",
			"http",
			"yaml",
			"toml",
		},
		auto_install = true,
		highlight = {
			enable = true,
			disable = {},
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby" } },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		-- Workaround: nvim 0.12 can yield nodes with broken :range() in
		-- markdown injection queries. Override the directive with a nil guard.
		local query = require("vim.treesitter.query")
		local ok_pred, pred_mod = pcall(require, "nvim-treesitter.query_predicates")
		if ok_pred then
			local lang_map = {
				["c_sharp"] = "c_sharp",
				["c++"] = "cpp",
				["objective-c"] = "objc",
			}
			local function get_parser_from_info(str)
				return lang_map[str] or str
			end
			pcall(query.add_directive, "set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
				local capture_id = pred[2]
				local node = match[capture_id]
				if not node then
					return
				end
				local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
				if not ok or not text then
					return
				end
				metadata["injection.language"] = get_parser_from_info(text:lower())
			end, { force = true, all = false })
		end
	end,
}
