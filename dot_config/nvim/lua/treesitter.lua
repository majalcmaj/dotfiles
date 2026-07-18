-- Native Treesitter (Neovim 0.12+) — no nvim-treesitter plugin.
--
-- Neovim ships a handful of parsers (c, lua, markdown, markdown_inline, query,
-- vim, vimdoc, diff, ...). Highlighting for any filetype with an available
-- parser is enabled below via vim.treesitter.start. Extra parsers are built
-- into the site parser dir by the :TSBuild command.
--
-- NOTE: tree-sitter based indentation is not part of core; indent falls back to
-- Neovim's builtin filetype indent. Folds use the native treesitter foldexpr.

-- Enable native highlighting + folds whenever a parser exists for the buffer.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("native-treesitter", { clear = true }),
	callback = function(args)
		local buf = args.buf
		local ft = vim.bo[buf].filetype
		local lang = vim.treesitter.language.get_lang(ft) or ft
		-- Only start if a parser is actually available; pcall guards the rest.
		if not pcall(vim.treesitter.language.add, lang) then
			return
		end
		if pcall(vim.treesitter.start, buf, lang) then
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo.foldmethod = "expr"
			-- Keep folds open by default; foldexpr stays available for `za`.
			vim.wo.foldenable = false
		end
	end,
})

-- Parser build list. Bundled parsers are intentionally omitted.
-- lang -> { url = git repo, [location] = subdir holding src/ (e.g. typescript) }
local grammars = {
	bash = { url = "https://github.com/tree-sitter/tree-sitter-bash" },
	go = { url = "https://github.com/tree-sitter/tree-sitter-go" },
	python = { url = "https://github.com/tree-sitter/tree-sitter-python" },
	javascript = { url = "https://github.com/tree-sitter/tree-sitter-javascript" },
	typescript = { url = "https://github.com/tree-sitter/tree-sitter-typescript", location = "typescript" },
	tsx = { url = "https://github.com/tree-sitter/tree-sitter-typescript", location = "tsx" },
	json = { url = "https://github.com/tree-sitter/tree-sitter-json" },
	yaml = { url = "https://github.com/tree-sitter-grammars/tree-sitter-yaml" },
	toml = { url = "https://github.com/tree-sitter-grammars/tree-sitter-toml" },
	html = { url = "https://github.com/tree-sitter/tree-sitter-html" },
	http = { url = "https://github.com/rest-nvim/tree-sitter-http" },
}

local function parser_dir()
	local dir = vim.fn.stdpath("data") .. "/site/parser"
	vim.fn.mkdir(dir, "p")
	return dir
end

-- Build a single grammar into the site parser dir. Returns ok, message.
local function build_one(lang, spec)
	local cc = vim.fn.exepath("cc")
	if cc == "" then
		cc = vim.fn.exepath("gcc")
	end
	if cc == "" then
		return false, "no C compiler (cc/gcc) on PATH"
	end
	if vim.fn.executable("git") == 0 then
		return false, "git not on PATH"
	end

	local cache = vim.fn.stdpath("cache") .. "/ts-build/" .. lang
	vim.fn.delete(cache, "rf")
	vim.fn.mkdir(cache, "p")

	local clone = vim.system({ "git", "clone", "--depth", "1", spec.url, cache }, { text = true }):wait()
	if clone.code ~= 0 then
		return false, "git clone failed: " .. (clone.stderr or "")
	end

	local src = cache .. (spec.location and ("/" .. spec.location) or "") .. "/src"
	local parser_c = src .. "/parser.c"
	if vim.fn.filereadable(parser_c) == 0 then
		return false, "no generated src/parser.c (needs tree-sitter CLI)"
	end

	local sources = { parser_c }
	for _, name in ipairs({ "scanner.c", "scanner.cc" }) do
		local p = src .. "/" .. name
		if vim.fn.filereadable(p) == 1 then
			table.insert(sources, p)
		end
	end

	-- Use a C++ compiler if any scanner is C++.
	local has_cpp = vim.fn.filereadable(src .. "/scanner.cc") == 1
	local compiler = cc
	if has_cpp then
		local cxx = vim.fn.exepath("c++")
		if cxx == "" then
			cxx = vim.fn.exepath("g++")
		end
		if cxx ~= "" then
			compiler = cxx
		end
	end

	local out = parser_dir() .. "/" .. lang .. ".so"
	local cmd = { compiler, "-shared", "-Os", "-fPIC", "-I" .. src, "-o", out }
	vim.list_extend(cmd, sources)

	local build = vim.system(cmd, { text = true }):wait()
	if build.code ~= 0 then
		return false, "compile failed: " .. (build.stderr or "")
	end
	return true, out
end

vim.api.nvim_create_user_command("TSBuild", function(opts)
	local targets = {}
	if #opts.fargs > 0 then
		for _, lang in ipairs(opts.fargs) do
			if grammars[lang] then
				targets[lang] = grammars[lang]
			else
				vim.notify("TSBuild: unknown grammar '" .. lang .. "'", vim.log.levels.WARN)
			end
		end
	else
		targets = grammars
	end

	for lang, spec in pairs(targets) do
		local already = not opts.bang and pcall(vim.treesitter.language.add, lang)
		if already then
			vim.notify("TSBuild: " .. lang .. " already available (use :TSBuild! to force)")
		else
			vim.notify("TSBuild: building " .. lang .. " ...")
			local ok, msg = build_one(lang, spec)
			if ok then
				vim.notify("TSBuild: " .. lang .. " -> " .. msg)
			else
				vim.notify("TSBuild: " .. lang .. " FAILED: " .. msg, vim.log.levels.ERROR)
			end
		end
	end
end, {
	nargs = "*",
	bang = true,
	desc = "Build tree-sitter parsers into the site parser dir (bang = rebuild even if present)",
	complete = function(arglead)
		local names = vim.tbl_keys(grammars)
		return vim.tbl_filter(function(n)
			return n:find(arglead, 1, true) == 1
		end, names)
	end,
})
