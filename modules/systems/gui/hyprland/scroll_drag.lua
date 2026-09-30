-- SUPER + middle drag scrolls the scrolling layout's tape with the mouse.

local POLL_MS = 16
local DRAG_KEY = "SUPER + mouse:274"

local timer = nil
local lastX = nil

local function stop()
	if timer then
		timer:set_enabled(false)
		timer = nil
	end

	lastX = nil
end

local function tick()
	if not (hl.is_key_down("Super_L") or hl.is_key_down("Super_R")) then
		stop()
		return
	end

	local pos = hl.get_cursor_pos()
	if not pos then
		stop()
		return
	end

	local dx = pos.x - lastX
	lastX = pos.x

	if dx ~= 0 then
		hl.dsp.layout(("move %d"):format(dx))()
	end
end

local function start()
	if timer then
		return
	end

	local pos = hl.get_cursor_pos()
	if not pos then
		return
	end

	lastX = pos.x
	timer = hl.timer(tick, { timeout = POLL_MS, type = "repeat" })
end

hl.bind(DRAG_KEY, start, { mouse = true })
hl.bind(DRAG_KEY, stop, { mouse = true, release = true })
