-- Niri's touchpad normalization and swipe tracker defaults.
local WORKING_AREA_MOVEMENT = 1200
local HISTORY_LIMIT_MS = 150
local DECELERATION = 0.997

local state
local animation_rule = hl.window_rule({
	name = "scrolling-gesture",
	enabled = false,
	match = { float = false },
	no_anim = true,
})

local function active_workspace()
	return hl.get_active_special_workspace() or hl.get_active_workspace()
end

local function restore_focus()
	if state then
		hl.config({ scrolling = { follow_focus = state.follow_focus } })
		state = nil
	end
end

local function reset()
	animation_rule:set_enabled(false)
	restore_focus()
end

local function check_context()
	if
		state
		and (
			active_workspace() ~= state.workspace
			or hl.get_active_monitor() ~= state.monitor
			or state.workspace.tiled_layout ~= "scrolling"
		)
	then
		reset()
	end
end

local function track(delta, time_ms)
	local history = state.history
	if #history > 0 and time_ms < history[#history].time_ms then
		return false
	end
	table.insert(history, { delta = delta, time_ms = time_ms })
	while time_ms - history[1].time_ms > HISTORY_LIMIT_MS do
		table.remove(history, 1)
	end
	return true
end

local function projected_motion()
	local history = state.history
	local duration = history[#history].time_ms - history[1].time_ms
	if duration == 0 then
		return 0
	end
	local delta = 0
	for _, sample in ipairs(history) do
		delta = delta + sample.delta
	end
	return -(delta / duration) / math.log(DECELERATION)
end

local function snap_offset(projected)
	local columns, seen = {}, {}
	local border = hl.get_config("general.border_size")
	for _, window in ipairs(hl.get_windows({ workspace = state.workspace, floating = false })) do
		local layout = window.layout
		if layout and layout.column and not window.hidden and not seen[layout.column.index] then
			seen[layout.column.index] = true
			local left = window.at.x - border
			table.insert(columns, { left = left, right = window.at.x + window.size.x + border })
		end
	end
	if #columns == 0 then
		return
	end
	table.sort(columns, function(a, b)
		return a.left < b.left
	end)

	-- Edge-aligned snaps, bounded by the first and last columns, as in Niri's default layout.
	local first = state.left - columns[1].left
	local last = state.right - columns[#columns].right
	local best = first
	local function consider(offset)
		if math.abs(offset - projected) < math.abs(best - projected) then
			best = offset
		end
	end
	consider(last)
	for _, column in ipairs(columns) do
		for _, offset in ipairs({ state.left - column.left, state.right - column.right }) do
			if last < offset and offset < first then
				consider(offset)
			end
		end
	end
	return best
end

local function move(delta)
	return hl.dispatch(hl.dsp.layout(string.format("move %.9f", delta))).ok
end

hl.on("config.unload", reset)
hl.on("workspace.active", check_context)
hl.on("workspace.special_active", check_context)
hl.on("monitor.focused", check_context)
hl.on("monitor.removed", check_context)

return {
	-- Hyprland delivers the start delta again in the first update.
	start = function()
		reset()
		local workspace = active_workspace()
		local monitor = hl.get_active_monitor()
		if not workspace or not monitor or workspace.tiled_layout ~= "scrolling" then
			return
		end

		local gaps = hl.get_config("general.gaps_out")
		local left = monitor.x + monitor.reserved.left + gaps.left
		local right = monitor.x + monitor.mode.width - monitor.reserved.right - gaps.right
		if right <= left then
			return
		end
		state = {
			workspace = workspace,
			monitor = monitor,
			follow_focus = hl.get_config("scrolling.follow_focus"),
			left = left,
			right = right,
			scale = (right - left) / WORKING_AREA_MOVEMENT,
			history = {},
		}
		hl.config({ scrolling = { follow_focus = false } })
		animation_rule = hl.window_rule({
			name = "scrolling-gesture",
			match = { workspace = workspace.addressable_name },
			enabled = true,
		})
		animation_rule:set_enabled(true)
	end,
	update = function(event)
		check_context()
		if not state then
			return
		end
		local delta = event.delta.x * state.scale
		if track(delta, event.time_ms) and delta ~= 0 and not move(delta) then
			reset()
		end
	end,
	finish = function(event)
		check_context()
		if state then
			-- Include the pause before lifting the fingers in the release velocity.
			track(0, event.time_ms)
			local offset = snap_offset(projected_motion())
			animation_rule:set_enabled(false)
			if offset then
				move(offset)
			end
			restore_focus()
		end
	end,
}
