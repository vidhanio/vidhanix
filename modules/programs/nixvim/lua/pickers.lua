local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")

local M = {}
local H = {}

M.centered = function()
	local height = math.floor(0.5 * vim.o.lines)
	local width = math.floor(0.5 * vim.o.columns)
	return {
		anchor = "NW",
		row = math.floor(0.5 * (vim.o.lines - height)),
		col = math.floor(0.5 * (vim.o.columns - width)),
		height = height,
		width = width,
	}
end

M.at_cursor = function()
	local state = MiniPick.get_picker_state()
	local target = (state ~= nil and state.windows ~= nil and state.windows.target ~= nil) and state.windows.target
		or vim.api.nvim_get_current_win()

	local cursor = vim.api.nvim_win_get_cursor(target)
	local pos = vim.fn.screenpos(target, cursor[1], cursor[2] + 1)

	local height = math.min(20, vim.o.lines - 4)
	local width = math.min(80, math.floor(0.618 * vim.o.columns))

	local row = pos.row
	if row + height + 2 > vim.o.lines then
		row = math.max(0, pos.row - height - 3)
	end

	local col = pos.col - 1
	if col + width + 2 > vim.o.columns then
		col = math.max(0, vim.o.columns - width - 2)
	end

	return {
		relative = "editor",
		anchor = "NW",
		row = row,
		col = col,
		height = height,
		width = width,
	}
end

M.buffers = function()
	MiniPick.builtin.buffers(nil, { window = { config = M.centered } })
end

M.files = function()
	MiniPick.builtin.files(nil, { window = { config = M.centered } })
end

M.grep = function()
	MiniPick.builtin.grep_live(nil, { window = { config = M.centered } })
end

M.diagnostics = function()
	MiniExtra.pickers.diagnostic({ scope = "all" }, { window = { config = M.centered } })
end

M.symbols = function()
	MiniExtra.pickers.lsp({ scope = "document_symbol" }, { window = { config = M.centered } })
end

M.setup = function()
	vim.ui.select = function(items, opts, on_choice)
		return MiniPick.ui_select(items, opts, on_choice, { window = { config = M.at_cursor } })
	end
end

H.filename = function(text)
	return text:match("([^/]+)$") or text
end

H.buffers = function()
	local bufs = vim.tbl_filter(function(buf)
		return buf.name ~= "" and vim.bo[buf.bufnr].buftype == "" and vim.fn.filereadable(buf.name) == 1
	end, vim.fn.getbufinfo({ buflisted = 1 }))
	table.sort(bufs, function(a, b)
		return a.lastused > b.lastused
	end)

	local items, seen = {}, {}
	for _, buf in ipairs(bufs) do
		local text = vim.fn.fnamemodify(buf.name, ":.")
		if not seen[text] then
			seen[text] = true
			items[#items + 1] = { text = text, path = buf.name, bufnr = buf.bufnr }
		end
	end
	return items, seen
end

H.postprocess = function(paths)
	local items, seen = H.buffers()
	H.buffer_texts = {}
	for _, item in ipairs(items) do
		H.buffer_texts[item.text:lower()] = true
	end

	local files = {}
	for _, path in ipairs(paths) do
		if path ~= "" then
			local text = vim.fn.fnamemodify(path, ":.")
			if not seen[text] then
				seen[text] = true
				files[#files + 1] = { text = text, path = path }
			end
		end
	end
	table.sort(files, function(a, b)
		return a.text < b.text
	end)

	return vim.list_extend(items, files)
end

H.show = function(buf_id, items, query)
	MiniPick.default_show(buf_id, items, query, { show_icons = true })
end

H.match = function(stritems, inds, query)
	if #query == 0 then
		return vim.fn.range(1, #stritems)
	end

	local q = table.concat(query)
	local texts, index, filenames = {}, {}, {}
	for _, i in ipairs(inds) do
		local text = stritems[i]
		texts[#texts + 1] = text
		index[text] = i
		filenames[#filenames + 1] = H.filename(text)
	end

	local filename_matches = {}
	for _, name in ipairs(vim.fn.matchfuzzypos(filenames, q)[1]) do
		filename_matches[name] = true
	end

	local matched, _, scores = unpack(vim.fn.matchfuzzypos(texts, q))
	local rank, score = {}, {}
	for i, text in ipairs(matched) do
		rank[text] = i
		score[text] = scores[i]
			* (H.buffer_texts[text:lower()] and 2 or 1)
			* (filename_matches[H.filename(text)] and 3 or 1)
	end

	table.sort(matched, function(a, b)
		if score[a] ~= score[b] then
			return score[a] > score[b]
		end
		return rank[a] < rank[b]
	end)

	return vim.tbl_map(function(text)
		return index[text]
	end, matched)
end

M.smart = function()
	return MiniPick.builtin.cli({
		command = { "rg", "--files", "--hidden", "--glob", "!.git" },
		postprocess = H.postprocess,
	}, {
		source = { name = "Smart Open", show = H.show, match = H.match },
		window = { config = M.centered },
	})
end

return M
