return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true, json = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 1500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format", "black", stop_after_first = true },
			json = { "jq" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			go = { "gofmt" },
		},
	},
	init = function()
		local skip_ft = { text = true, help = true, markdown = true, json = true, nofile = true, [""] = true }
		local warned = {}
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("conform-warn-no-formatter", { clear = true }),
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				if skip_ft[ft] or warned[ft] then
					return
				end
				local formatters = require("conform").list_formatters(args.buf)
				if #formatters == 0 then
					warned[ft] = true
					vim.notify("No formatter for filetype: " .. ft, vim.log.levels.WARN)
				end
			end,
		})
	end,
}
