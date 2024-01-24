local util = require("util")
local compress = require("compress")
local decompress = require("decompress")

--- Clear the current visual selection.
local function clear_selection()
	vim.api.nvim_buf_set_mark(0, "<", 0, 0, {})
	vim.api.nvim_buf_set_mark(0, ">", 0, 0, {})
end

--- Compress a one-line block or decompress a multi-line block.
local function flex()
	if vim.fn.search("[(){}[\\]]", "scW") == 0 then
		return
	end

	vim.schedule(function()
		clear_selection()
		util.select_block()

		vim.schedule(function()
			local sel_first_row, sel_last_row = util.get_selection()
			local lines = util.get_lines(sel_first_row, sel_last_row)
			local blocktype = util.getchar()

			local output = nil
			if sel_first_row == sel_last_row then
				local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
				output = decompress(lines[1], blocktype, shiftwidth)
			else
				output = { compress(lines, blocktype) }
			end

			util.insert_lines(sel_first_row, sel_last_row, output)
		end)
	end)
end

return { flex = flex }
