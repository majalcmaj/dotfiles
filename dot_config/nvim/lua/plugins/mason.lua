-- Mason: install LSP servers and tools (formatters, etc.) to stdpath for Neovim.
--
-- Native LSP config lives in `lsp/*.lua` and is enabled in `lua/lsp.lua`.
-- Mason here only handles installing the binaries; mason.nvim prepends its bin
-- dir to PATH so the `cmd` in each lsp/*.lua resolves.
return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },
	},
	config = function()
		require("mason").setup()

		-- Ensure servers and tools are installed. These are Mason package names.
		--    Run :Mason to see status / install more; press g? for help.
		require("mason-tool-installer").setup({
			ensure_installed = {
				"lua-language-server",
				"pyright",
				"gopls",
				"typescript-language-server",
				"terraform-ls",
				"stylua", -- Used to format Lua code
				"java-language-server",
			},
		})

		-- We enable servers explicitly in lua/lsp.lua via vim.lsp.enable, so let
		-- mason-lspconfig manage only its name mapping, not automatic enabling.
		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_enable = false,
		})
	end,
}
