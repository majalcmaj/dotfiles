local map = vim.keymap.set
map('n', '<leader>bD', function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, i in ipairs(vim.api.nvim_list_bufs()) do
    if i ~= current_buf then
      local type = vim.api.nvim_get_option_value('buftype', { buf = i })
      if type ~= 'nofile' and vim.api.nvim_buf_get_option(i, 'modified') then
        vim.api.nvim_buf_call(i, function()
          vim.cmd 'w'
        end)
      end
      vim.api.nvim_buf_delete(i, {})
    end
  end
end, { desc = 'Close all buffers except current' })
