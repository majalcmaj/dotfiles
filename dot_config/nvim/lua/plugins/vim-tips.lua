return {
  'saxon1964/neovim-tips',
  version = '*', -- Only update on tagged releases
  lazy = false,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'MeanderingProgrammer/render-markdown.nvim', -- Rich rendering with advanced features
  },
  opts = {
    -- OPTIONAL: Location of user defined tips (default value shown below)
    user_file = vim.fn.stdpath 'config' .. '/neovim_tips/user_tips.md',
    user_tip_prefix = '[User] ',
    warn_on_conflicts = true,
    -- 0 = off, 1 = once per day, 2 = every startup
    daily_tip = 1,
    bookmark_symbol = '🌟 ',
  },
}

