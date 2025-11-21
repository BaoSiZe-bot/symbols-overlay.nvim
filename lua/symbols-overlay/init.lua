local M = {}
M.overlays = {} -- Save groups: { word = "foo", hl = "Overlay1", id = 123 }
local colors = {
	{ bg = "#ff5555", fg = "#000000", bold = true },
	{ bg = "#ffb86c", fg = "#000000", bold = true },
	{ bg = "#f1fa8c", fg = "#000000", bold = true },
	{ bg = "#50fa7b", fg = "#000000", bold = true },
	{ bg = "#8be9fd", fg = "#000000", bold = true },
	{ bg = "#bd93f9", fg = "#000000", bold = true },
	{ bg = "#ff79c6", fg = "#000000", bold = true },
	{ bg = "#f06292", fg = "#000000", bold = true },
	{ bg = "#ff5555", fg = "#000000", bold = true },
}
M.default_config = {
	colors = { -- 10 preset colors
		"SymbolOverlay1",
		"SymbolOverlay2",
		"SymbolOverlay3",
		"SymbolOverlay4",
		"SymbolOverlay5",
		"SymbolOverlay6",
		"SymbolOverlay7",
		"SymbolOverlay8",
		"SymbolOverlay9",
	},
}
M.config = vim.deepcopy(M.default_config)

function M.colors_setup()
	for i, color in ipairs(colors) do
		local hl = "SymbolOverlay" .. i
		local ok = vim.api.nvim_get_hl(0, { name = hl })
		if not ok.bg then
			vim.api.nvim_set_hl(0, hl, color)
		end
	end
end

-- Add current word to new color group
function M.add()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end

	local idx = #M.overlays % #M.config.colors + 1
	local hl = "SymbolOverlay" .. idx

	-- Match the full word only
	local pattern = "\\<" .. word .. "\\>"
	local id = vim.fn.matchadd(hl, pattern, 100) -- give a high priority

	table.insert(M.overlays, { word = word, hl = hl, id = id, pattern = pattern })
	-- print("Overlay +" .. idx .. ": " .. word .. " → " .. bg)
end

-- Remove the word under cursor from overlays
function M.remove()
	local word = vim.fn.expand("<cword>")
	for i = #M.overlays, 1, -1 do
		if M.overlays[i].word == word then
			pcall(vim.fn.matchdelete, M.overlays[i].id)
			table.remove(M.overlays, i)
			-- print("Overlay removed: " .. word)
			break
		end
	end
end

function M.clear()
	for i = #M.overlays, 1, -1 do
		pcall(vim.fn.matchdelete, M.overlays[i].id)
		table.remove(M.overlays, i)
	end
end

local function is_overlayed(word)
	for _, v in ipairs(M.overlays) do
		if v.word == word then
			return v
		end
	end
	return false
end

function M.toggle()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end

	local exists = is_overlayed(word)
	if exists then
		M.remove()
	else
		M.add()
	end
end

function M.next()
	if #M.overlays == 0 then
		return
	end
	local word = vim.fn.expand("<cword>")
	for _, v in ipairs(M.overlays) do
		if v.word == word then
			vim.fn.search(v.pattern, "w")
			vim.cmd("normal! zz")
			return
		end
	end
end

function M.prev()
	if #M.overlays == 0 then
		return
	end
	local word = vim.fn.expand("<cword>")
	for _, v in ipairs(M.overlays) do
		if v.word == word then
			vim.fn.search(v.pattern, "wb")
			vim.cmd("normal! zz")
			return
		end
	end
end

-- Query replace all occurrences of current word in buffer
function M.rename()
	local old = vim.fn.expand("<cword>")
	local new = vim.fn.input("Replace '" .. old .. "' with → ")
	if new == "" or new == old then
		return
	end

	-- Remove the overlay first
	M.remove()

	vim.cmd(string.format("%%s/\\<%s\\>/%s/gc", old, new))

	-- Add the new word back (inherit the original color)
	vim.fn.setreg("/", "\\<" .. vim.fn.escape(new, "/\\") .. "\\>")
	M.add()
end

local function find_nearest_overlay(dir)
	if #M.overlays == 0 then
		return
	end

	local cur_pos = vim.api.nvim_win_get_cursor(0) -- [row, col] (1-based)
	local cur_line, cur_col = cur_pos[1], cur_pos[2]
	local positive_max_dist = 1
	local positive_min_dist = math.huge
	local negative_min_dist = -1
	local negative_max_dist = -math.huge
	local positive_max_pos = nil
	local positive_min_pos = nil
	local negative_max_pos = nil
	local negative_min_pos = nil

	-- nvim_win_get_cursor is very strange, cur_line is 1-based, but cur_col is 0-based
	cur_col = cur_col + 1

	for _, ov in ipairs(M.overlays) do
		local flags = (dir > 0) and "" or "b"
		local pos = vim.fn.searchpos(ov.pattern, flags .. "n")

		if pos[1] ~= 0 then
			local line_diff = pos[1] - cur_line
			local col_diff = pos[2] - cur_col

			local dist = line_diff * 1000000 + col_diff -- Ensure same line is always closer than cross line

			-- print(ov.pattern .. "'s line is " .. pos[1] .. ", col is " .. pos[2])
			-- print(ov.pattern .. "'s dist is " .. dist)

			if dist < 0 then
				if dist < negative_min_dist then
					negative_min_dist = dist
					negative_min_pos = pos
				end
				if dist > negative_max_dist then
					negative_max_dist = dist
					negative_max_pos = pos
				end
			else
				if dist > 0 then
					if dist < positive_min_dist then
						positive_min_dist = dist
						positive_min_pos = pos
					end
					if dist > positive_max_dist then
						positive_max_dist = dist
						positive_max_pos = pos
					end
				else
					-- do nothing if there are only one match for this pattern
				end
			end
		end
	end

	-- print("positive_min_pos:", vim.inspect(positive_min_pos))
	-- print("negative_max_pos:", vim.inspect(negative_max_pos))
	-- print("negative_min_pos:", vim.inspect(negative_min_pos))
	-- print("positive_max_pos:", vim.inspect(positive_max_pos))

	if dir > 0 then
		if positive_min_pos then
			return positive_min_pos
		else
			return negative_min_pos -- wrap
		end
	else
		if negative_max_pos then
			return negative_max_pos
		else
			return positive_max_pos -- wrap
		end
	end
end

function M.switch_forward()
	if #M.overlays == 0 then
		return print("No overlays")
	end
	local pos = find_nearest_overlay(1)
	if pos then
		vim.fn.cursor(pos)
		vim.cmd("normal! zz")
		local word = vim.fn.expand("<cword>")
		local idx = 0
		for i, v in ipairs(M.overlays) do
			if v.word == word then
				idx = i
				break
			end
		end
		-- print("→ " .. word .. " (Overlay " .. idx .. ")")
	else
		-- print("No more forward") -- This should not appears
	end
end

function M.switch_backward()
	-- if #M.overlays == 0 then
	-- 	return print("No overlays")
	-- end
	local pos = find_nearest_overlay(-1)
	if pos then
		vim.fn.cursor(pos)
		vim.cmd("normal! zz")
		local word = vim.fn.expand("<cword>")
		local idx = 0
		for i, v in ipairs(M.overlays) do
			if v.word == word then
				idx = i
				break
			end
		end
		-- print("← " .. word .. " (Overlay " .. idx .. ")")
	else
		-- print("No more backward") -- This should not appears
	end
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	M.colors_setup()
end

return M
