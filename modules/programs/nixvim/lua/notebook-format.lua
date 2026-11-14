local M = {}

function M.is_notebook(buf)
	local ok, notebook = pcall(require, "jupynvim.notebook")
	return ok and notebook.get(buf) ~= nil
end

function M.format(_, ctx, lines, callback)
	local notebook = require("jupynvim.notebook")
	local nb = assert(notebook.get(ctx.buf), "Not a Jupynvim notebook")
	if nb.alias then
		callback("Notebook formatting requires a local project")
		return
	end

	local tick = vim.api.nvim_buf_get_changedtick(ctx.buf)
	local snapshot = { cells = {} }
	for _, cell in ipairs(nb.cells) do
		snapshot.cells[#snapshot.cells + 1] = {
			id = cell.id,
			cell_type = cell.cell_type,
			metadata = vim.empty_dict(),
			outputs = cell.cell_type == "code" and {} or nil,
			execution_count = cell.cell_type == "code" and vim.NIL or nil,
		}
	end
	-- Parse the formatter's input, not the potentially stale notebook model.
	nb.sync_from_buffer(snapshot, lines)
	local document = {
		nbformat = 4,
		nbformat_minor = 5,
		metadata = vim.empty_dict(),
		cells = snapshot.cells,
	}

	local scratch = vim.api.nvim_create_buf(false, false)
	local ok, output = pcall(function()
		local filename = vim.api.nvim_buf_get_name(ctx.buf)
		vim.api.nvim_buf_set_name(
			scratch,
			vim.fs.dirname(filename)
				.. "/.conform."
				.. vim.fs.basename(vim.fn.tempname())
				.. "."
				.. vim.fs.basename(filename)
		)
		vim.bo[scratch].filetype = "ipynb"
		local json = vim.json.encode(document)
		vim.api.nvim_buf_set_lines(scratch, 0, -1, false, { json })
		-- Format ordinary notebook JSON using the configured ipynb pipeline.
		local conform = require("conform")
		local formatters = conform.list_formatters_to_run(scratch)
		assert(#formatters > 0, "No Conform formatters available for ipynb")
		local err, formatted_lines = conform.format_lines(
			vim.tbl_map(function(formatter)
				return formatter.name
			end, formatters),
			{ json },
			{ bufnr = scratch, async = false, timeout_ms = 5000 }
		)
		if err then
			error(err.message)
		end
		local formatted = vim.json.decode(table.concat(formatted_lines, "\n"))
		assert(#formatted.cells == #snapshot.cells, "Formatter changed notebook cell count")
		for i, cell in ipairs(formatted.cells) do
			local original = snapshot.cells[i]
			assert(
				cell.id == original.id and cell.cell_type == original.cell_type,
				"Formatter changed notebook cell identity"
			)
			if type(cell.source) == "table" then
				cell.source = table.concat(cell.source)
			end
			assert(type(cell.source) == "string", "Formatter returned invalid cell source")
		end
		assert(
			vim.api.nvim_buf_is_valid(ctx.buf) and vim.api.nvim_buf_get_changedtick(ctx.buf) == tick,
			"Notebook changed while formatting; discarded result"
		)

		-- Replace only changed sources; keep outputs and separators intact.
		local regions = { { start = 1 } }
		for i, line in ipairs(lines) do
			local region = regions[#regions]
			if line == notebook.OUT_SEP then
				region.stop = region.stop or i
			elseif line == notebook.CELL_SEP then
				region.stop = region.stop or i
				regions[#regions + 1] = { start = i + 1 }
			end
		end
		regions[#regions].stop = regions[#regions].stop or (#lines + 1)
		local out, cursor = {}, 1
		for i, region in ipairs(regions) do
			vim.list_extend(out, vim.list_slice(lines, cursor, region.start - 1))
			if formatted.cells[i].source ~= snapshot.cells[i].source then
				local source = formatted.cells[i].source:gsub("\n$", "")
				for _, line in ipairs(vim.split(source, "\n", { plain = true })) do
					out[#out + 1] = notebook._marker_ish(line) and (line .. " ") or line
				end
			else
				vim.list_extend(out, vim.list_slice(lines, region.start, region.stop - 1))
			end
			cursor = region.stop
		end
		vim.list_extend(out, vim.list_slice(lines, cursor))
		return out
	end)
	vim.api.nvim_buf_delete(scratch, { force = true })
	if ok then
		callback(nil, output)
	else
		callback(tostring(output))
	end
end

-- Command mode locks the buffer; keep that lock outside the synchronous edit.
function M.format_buffer(buf)
	assert(M.is_notebook(buf), "Not a Jupynvim notebook")
	local modifiable = vim.bo[buf].modifiable
	vim.bo[buf].modifiable = true
	local format_err
	local ok, err = pcall(function()
		require("conform").format({
			bufnr = buf,
			async = false,
			timeout_ms = 5000,
			formatters = { "notebook_cells" },
			lsp_format = "never",
		}, function(result)
			format_err = result
		end)
	end)
	if vim.api.nvim_buf_is_valid(buf) then
		vim.bo[buf].modifiable = modifiable
	end
	if not ok or format_err then
		error("Notebook formatting failed: " .. tostring(format_err or err))
	end
end

function M.setup()
	vim.api.nvim_create_user_command("JupynvimFormat", function()
		M.format_buffer(vim.api.nvim_get_current_buf())
	end, { desc = "Format notebook cells with Conform's ipynb formatters" })
end

return M
