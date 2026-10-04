local MiniPick = require("mini.pick")

local M = {}

local H = {}

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

function M.picker()
	return MiniPick.builtin.cli({
		command = { "rg", "--files", "--hidden", "--glob", "!.git" },
		postprocess = H.postprocess,
	}, {
		source = { name = "Smart Open", show = H.show, match = H.match },
	})
end

return M
