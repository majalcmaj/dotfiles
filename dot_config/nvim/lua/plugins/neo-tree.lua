-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if #vim.api.nvim_list_wins() == 1 and require("neo-tree.utils").is_neotree_buffer() then
			vim.cmd("quit")
		end
	end,
})

return {
	"nvim-neo-tree/neo-tree.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		"MunifTanjim/nui.nvim",
		"antosha417/nvim-lsp-file-operations",
	},
	lazy = false,
	keys = {
		{ "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			filesystem = {
				window = {
					mappings = {
						["\\"] = "close_window",
					},
				},
			},
		})
	end,
}
