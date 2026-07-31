return {
	"NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically
	config = function()
		require("guess-indent").setup({
			auto_cmd = true,
			override_editorconfig = false,
		})
	end,
}
