local util = require("util")
local compress = require("compress")
local decompress = require("decompress")

--- Move the cursor to the next bracket.
--- Return 0 if no bracket is found.
local function move_to_next_bracket()
	return vim.fn.search("[(){}[\\]]", "csW")
end

--- Compress or decompress a block.
local function toggle(lines, blocktype)
	if #lines == 1 then
		local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
		return decompress(lines[1], blocktype, shiftwidth)
	end
	return { compress(lines, blocktype) }
end

local function flex()
	if move_to_next_bracket() == 0 then
		return
	end
	vim.schedule(util.select_block)
	vim.schedule(function()
		local first_row, last_row = util.get_selection()
		local old_lines = util.get_lines(first_row, last_row)
		local blocktype = util.getchar()
		local new_lines = toggle(old_lines, blocktype)
		util.insert_lines(first_row, last_row, new_lines)
	end)
end

return { flex = flex }
