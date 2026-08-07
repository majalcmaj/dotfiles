-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    'MunifTanjim/nui.nvim',
    'antosha417/nvim-lsp-file-operations',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  init = function()
    -- Close Neo-tree when the last real file buffer is deleted (`:bd`, bufferline close, etc.).
    -- The built-in close_if_last_window only reacts to WinClosed, so it misses this case.
    vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
      group = vim.api.nvim_create_augroup('neotree-close-if-last', { clear = true }),
      callback = function(args)
        vim.schedule(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local is_file = buf ~= args.buf
              and vim.api.nvim_buf_is_valid(buf)
              and vim.bo[buf].buflisted
              and vim.bo[buf].buftype == ''
              and vim.api.nvim_buf_get_name(buf) ~= ''
            if is_file then
              return
            end
          end

          local neotree_wins, other_wins = {}, 0
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(win).relative == '' then
              if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'neo-tree' then
                neotree_wins[#neotree_wins + 1] = win
              else
                other_wins = other_wins + 1
              end
            end
          end

          if #neotree_wins == 0 then
            return
          end
          if other_wins == 0 then
            vim.cmd 'qa'
          else
            vim.cmd 'Neotree close'
          end
        end)
      end,
    })
  end,
  opts = {
    close_if_last_window = true,
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
