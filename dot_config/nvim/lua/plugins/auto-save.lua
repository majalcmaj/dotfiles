return {
	"okuuva/auto-save.nvim",
	event = { "InsertLeave", "TextChanged" },
	opts = {
		write_all_buffers = true,
		debounce_delay = 500,
	},
}
