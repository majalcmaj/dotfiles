return {

  { -- Linting
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        python = { 'ruff' },
        javascript = { 'eslint' },
        typescript = { 'eslint' },
      }

      local ensure_installed = vim.iter(vim.tbl_values(lint.linters_by_ft)):flatten():totable()
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            -- Ignore errors to avoid error when a linter is not installed
            lint.try_lint(nil, { ignore_errors = true })
          end
        end,
      })
    end,
  },
}
