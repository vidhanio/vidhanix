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

	local filename = vim.api.nvim_buf_get_name(ctx.buf)
	local dirname = vim.fs.dirname(filename)
	local temp = dirname .. "/.conform." .. vim.fs.basename(vim.fn.tempname()) .. "." .. vim.fs.basename(filename)
	local fd, open_err = vim.uv.fs_open(temp, "wx", 384)
	if not fd then
		callback(open_err)
		return
	end
	local json = vim.json.encode(document)
	local written, write_err = vim.uv.fs_write(fd, json, 0)
	vim.uv.fs_close(fd)
	if written ~= #json then
		vim.uv.fs_unlink(temp)
		callback(write_err or "Could not write temporary notebook")
		return
	end

	local function finish(result)
		local ok, output = pcall(function()
			if result.code ~= 0 then
				error(result.stderr ~= "" and result.stderr or "treefmt failed")
			end
			local formatted = vim.json.decode(table.concat(vim.fn.readfile(temp), "\n"))
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

			-- Keep markdown, rendered outputs, and separators byte-for-byte intact.
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
				if snapshot.cells[i].cell_type == "code" then
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
		vim.uv.fs_unlink(temp)
		if ok then
			callback(nil, output)
		else
			callback(tostring(output))
		end
	end

	local ok, err = pcall(
		vim.system,
		{ "treefmt", "--no-cache", temp },
		{ cwd = dirname, text = true, timeout = 5000 },
		vim.schedule_wrap(finish)
	)
	if not ok then
		vim.uv.fs_unlink(temp)
		callback(tostring(err))
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
			formatters = { "notebook_treefmt" },
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
	end, { desc = "Format notebook code cells with project treefmt" })
end

return M
