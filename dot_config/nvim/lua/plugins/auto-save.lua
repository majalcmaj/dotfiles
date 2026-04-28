return {
	"Pocco81/auto-save.nvim",
	opts = {
		write_all_buffers = true,
		debounce_delay = 1500,
		execution_message = {
			message = function()
				return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
			end,
			dim = 0.18,
		},
	},
}
