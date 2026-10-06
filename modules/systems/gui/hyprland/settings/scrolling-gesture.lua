local state
local animation_rule = hl.window_rule({
	name = "scrolling-gesture",
	enabled = false,
	match = { float = false },
	no_anim = true,
})

local restore_animation

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
	restore_focus()
	if restore_animation then
		restore_animation:set_enabled(false)
	end
	animation_rule:set_enabled(false)
end

local function same_context()
	return state
		and active_workspace() == state.workspace
		and hl.get_active_monitor() == state.monitor
		and state.workspace.tiled_layout == "scrolling"
end

local function check_context()
	if state and not same_context() then
		reset()
	end
end

local function bounds(workspace, monitor)
	local first, last
	for _, window in ipairs(hl.get_windows({ workspace = workspace, floating = false })) do
		if window.layout and not window.hidden then
			local left = window.at.x
			local right = left + window.size.x
			local column = { left = left, right = right, center = (left + right) / 2 }
			if not first or column.center < first.center then
				first = column
			end
			if not last or column.center > last.center then
				last = column
			end
		end
	end
	if not first then
		return
	end

	local reserved = monitor.reserved
	local gaps = hl.get_config("general.gaps_out")
	local left = monitor.x + reserved.left + gaps.left
	local right = monitor.x + monitor.mode.width - reserved.right - gaps.right
	local center = (left + right) / 2
	return math.min(0, center - last.center, right - last.right), math.max(0, center - first.center, left - first.left)
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

		local min_delta, max_delta = bounds(workspace, monitor)
		if not min_delta then
			return
		end
		state = {
			workspace = workspace,
			monitor = monitor,
			follow_focus = hl.get_config("scrolling.follow_focus"),
			delta = 0,
			min_delta = min_delta,
			max_delta = max_delta,
		}
		hl.config({ scrolling = { follow_focus = false } })
		if not restore_animation then
			-- Leave no_anim enabled until the final motion has reached a frame.
			restore_animation = hl.timer(function()
				animation_rule:set_enabled(false)
			end, { timeout = 50, type = "oneshot" })
			restore_animation:set_enabled(false)
		end
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
		local delta = math.max(state.min_delta, math.min(state.max_delta, state.delta + event.delta.x))
		if delta == state.delta then
			return
		end
		if move(delta - state.delta) then
			state.delta = delta
		else
			reset()
		end
	end,
	finish = function(event)
		check_context()
		if not state then
			return
		end
		if event.cancelled and state.delta ~= 0 then
			move(-state.delta)
		end
		restore_focus()
		restore_animation:set_timeout(50)
	end,
}
