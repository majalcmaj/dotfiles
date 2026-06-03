# Neovim Config Improvement Plan

## 1. Smart Formatter Detection (conform.lua)

**Problem:** Hardcoded `python = { "isort", "black" }`. No fallback, no warning when formatter missing.

**Fix:**
- Use `stop_after_first = true` with priority chain: `ruff_format` > `black`
- Drop `isort` — ruff handles import sorting
- Add same pattern for JS/TS: `prettierd` > `prettier`
- Add `go = { "gofmt" }`
- Add `BufWritePre` autocmd that warns (once) when no formatter found for non-trivial filetypes (skip `text`, `help`, `markdown`, `nofile`)

```lua
formatters_by_ft = {
  lua = { "stylua" },
  python = { "ruff_format", "black", stop_after_first = true },
  json = { "jq" },
  javascript = { "prettierd", "prettier", stop_after_first = true },
  typescript = { "prettierd", "prettier", stop_after_first = true },
  go = { "gofmt" },
},
```

---

## 2. Hotkey Discoverability

**Problem:** which-key spec groups incomplete. Many keymaps not grouped.

**Fix:**
- Add missing groups to which-key spec:
  - `<leader>b` → `[B]uffer/Breakpoint`
  - `<leader>9` → `[9]9 AI` (mode `n`, `v`)
  - `gr` → `LSP [G]oto/[R]efactor`
- Add `<leader>s?` as alias for keymap search (more intuitive than `<leader>sk`)
- Consider `m4xshen/hardtime.nvim` to teach efficient motions

---

## 3. Plugin Update Notifications

**Problem:** No awareness of outdated plugins.

**Fix:** Add lazy.nvim checker to `init.lua` opts:

```lua
checker = {
  enabled = true,
  notify = true,
  frequency = 86400,  -- check daily
},
change_detection = {
  enabled = true,
  notify = false,
},
```

**Re: chezmoi auto-push lockfile** — Don't auto-push. Instead:
- Shell alias: `alias nvim-update="nvim --headless '+Lazy! update' +qa && cd ~/.local/share/chezmoi && git add dot_config/nvim/lazy-lock.json && git commit -m 'chore: update nvim plugins' && git push"`

---

## 4. LSP Status in Statusline

**Problem:** No visibility into whether LSP is attached. `fidget.nvim` shows progress but not presence.

**Fix:** Customize `mini.statusline` active content to include LSP client names. Shows server name when attached, empty when not (no noise for `.txt` etc).

```lua
local lsp_names = {}
for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
  table.insert(lsp_names, client.name)
end
local lsp = #lsp_names > 0 and table.concat(lsp_names, ",") or ""
```

Place in statusline between filename and fileinfo sections.

---

## 5. Duplicate Gitsigns Config

**Problem:** `lua/plugins/gitsigns.lua` AND `lua/kickstart/plugins/gitsigns.lua` both exist. Only `lua/plugins/` auto-imported. Kickstart version (with keymaps) never loaded.

**Fix:** Merge keymaps from kickstart version into `lua/plugins/gitsigns.lua`, delete `lua/kickstart/plugins/gitsigns.lua`.

---

## 6. Deprecated API in mappings.lua

**Problem:** `vim.api.nvim_buf_get_option(i, 'modified')` deprecated since nvim 0.9.

**Fix:** Replace with `vim.api.nvim_get_option_value('modified', { buf = i })`.

---

## 7. Options Load Order

**Problem:** `options.lua` loaded via `vim.schedule` in init.lua — `tabstop`/`shiftwidth` set after plugins, could race with `guess-indent`.

**Fix:** Move core editor options (tabstop, shiftwidth, expandtab, softtabstop) into init.lua directly, before plugin load. Keep `options.lua` for plugin-dependent options only (like `formatexpr`).

---

## 8. Missing Treesitter Parsers

**Problem:** `ensure_installed` only has `bash, c, diff, html, lua, luadoc, markdown, markdown_inline, query, vim, vimdoc`. Missing languages actively used.

**Fix:** Add `python`, `go`, `javascript`, `typescript`, `json`, `http`, `yaml`, `toml`.

---

## 9. Unmaintained auto-save Plugin

**Problem:** `Pocco81/auto-save.nvim` is unmaintained/archived.

**Fix:** Switch to `okuuva/auto-save.nvim` (active fork, same API).

---

## 10. Session Persistence (Optional)

**Problem:** No session restore — lose buffer layout on close.

**Consider:** `folke/persistence.nvim` or `rmagatti/auto-session` to restore buffers/layout on reopen.


## 11. Markdown renderer problem
Troubleshoot and fix:
```
vim.schedule callback: .../neovim/0.12.2/share/nvim/runtime/lua/vim/treesitter.lua:196: attempt to call method 'range' (a nil value)
stack traceback:
        .../neovim/0.12.2/share/nvim/runtime/lua/vim/treesitter.lua:196: in function 'get_range'
        .../neovim/0.12.2/share/nvim/runtime/lua/vim/treesitter.lua:231: in function 'get_node_text'
        ...nvim-treesitter/lua/nvim-treesitter/query_predicates.lua:141: in function 'handler'
        ...m/0.12.2/share/nvim/runtime/lua/vim/treesitter/query.lua:868: in function '_apply_directives'
        ...m/0.12.2/share/nvim/runtime/lua/vim/treesitter/query.lua:1089: in function '(for generator)'
        ...2/share/nvim/runtime/lua/vim/treesitter/languagetree.lua:1123: in function '_get_injections'
        ...2/share/nvim/runtime/lua/vim/treesitter/languagetree.lua:690: in function '_parse'
        ...2/share/nvim/runtime/lua/vim/treesitter/languagetree.lua:639: in function 'parse'
        ...ender-markdown.nvim/lua/render-markdown/request/view.lua:62: in function 'parse'
        ...azy/render-markdown.nvim/lua/render-markdown/core/ui.lua:156: in function 'parse'
        ...azy/render-markdown.nvim/lua/render-markdown/core/ui.lua:129: in function 'render'
        ...azy/render-markdown.nvim/lua/render-markdown/core/ui.lua:112: in function 'run'
        ...azy/render-markdown.nvim/lua/render-markdown/core/ui.lua:78: in function <...azy/render-markdown.nvim/lua/render-markdown/core/ui.lua:77>
```
