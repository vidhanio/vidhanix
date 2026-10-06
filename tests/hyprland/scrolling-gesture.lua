local root = (arg[0]:match("^(.*)/tests/hyprland/") or ".")
local source = root .. "/modules/systems/gui/hyprland/settings/scrolling-gesture.lua"

local function fixture(options)
	options = options or {}
	local f = {
		workspace = { addressable_name = "1", tiled_layout = options.layout or "scrolling" },
		monitor = {
			x = 0,
			mode = { width = 2000 },
			reserved = { left = 0, right = 0 },
		},
		follow_focus = options.follow_focus ~= false,
		gaps = { left = 0, right = 0 },
		windows = {},
		moves = {},
		listeners = {},
		rule = { enabled = false, match = {} },
	}
	for _, x in ipairs({ 300, 1000, 1700 }) do
		table.insert(f.windows, {
			at = { x = x },
			size = { x = 400 },
			layout = {},
			workspace = f.workspace,
			floating = false,
		})
	end

	function f.rule:set_enabled(enabled)
		self.enabled = enabled
	end

	_G.hl = {
		get_active_workspace = function()
			return f.workspace
		end,
		get_active_special_workspace = function()
			return f.special_workspace
		end,
		get_active_monitor = function()
			return f.monitor
		end,
		get_windows = function(filters)
			local windows = {}
			for _, window in ipairs(f.windows) do
				if window.workspace == filters.workspace and window.floating == filters.floating then
					table.insert(windows, window)
				end
			end
			return windows
		end,
		get_config = function(key)
			if key == "scrolling.follow_focus" then
				return f.follow_focus
			end
			assert(key == "general.gaps_out")
			return f.gaps
		end,
		config = function(config)
			assert(config.scrolling and config.scrolling.follow_focus ~= nil)
			f.follow_focus = config.scrolling.follow_focus
		end,
		window_rule = function(rule)
			assert(rule.name == "scrolling-gesture")
			for key, value in pairs(rule.match) do
				f.rule.match[key] = value
			end
			f.rule.enabled = rule.enabled
			f.rule.no_anim = rule.no_anim or f.rule.no_anim
			return f.rule
		end,
		timer = function(callback, options)
			assert(options.type == "oneshot")
			f.timer = { enabled = true, timeout = options.timeout }
			function f.timer:set_enabled(enabled)
				self.enabled = enabled
			end
			function f.timer:set_timeout(timeout)
				self.timeout = timeout
				self.enabled = true
			end
			function f.timer:fire()
				if self.enabled then
					self.enabled = false
					callback()
				end
			end
			return f.timer
		end,
		on = function(event, callback)
			f.listeners[event] = callback
		end,
		dispatch = function(handler)
			return handler()
		end,
		dsp = {
			layout = function(message)
				return function()
					assert(f.rule.enabled and f.rule.no_anim)
					assert(f.rule.match.float == false and f.follow_focus == false)
					if f.fail_dispatch then
						return { ok = false }
					end
					local delta = assert(tonumber(message:match("^move (.+)$")))
					table.insert(f.moves, delta)
					for _, window in ipairs(f.windows) do
						if window.workspace == (f.special_workspace or f.workspace) and not window.floating then
							window.at.x = window.at.x + delta
						end
					end
					return { ok = true }
				end
			end,
		},
	}
	f.action = dofile(source)
	assert(not f.rule.enabled and not f.timer)

	function f:update(x, y)
		self.action.update({ delta = { x = x, y = y or 0 } })
	end
	function f:finish(cancelled)
		self.action.finish({ cancelled = cancelled or false })
	end
	return f
end

local count = 0
local function test(name, callback)
	callback()
	count = count + 1
	print("ok " .. count .. " - " .. name)
end

local function close(actual, expected)
	assert(math.abs(actual - expected) < 1e-8, tostring(actual) .. " ~= " .. tostring(expected))
end

test("fractional deltas are applied once, without easing, momentum or snapping", function()
	local f = fixture()
	f.action.start({ delta = { x = 12.25, y = 0 } })
	assert(#f.moves == 0)
	f:update(12.25, 10000)
	f:update(-3.75)
	f:update(0)
	assert(#f.moves == 2)
	close(f.moves[1], 12.25)
	close(f.moves[2], -3.75)
	f:finish()
	assert(#f.moves == 2 and f.follow_focus)
	assert(f.rule.enabled and f.timer.enabled)
	f.timer:fire()
	assert(not f.rule.enabled)
	f:update(100)
	f:finish()
	assert(#f.moves == 2)
end)

test("cancellation restores the original tape position", function()
	local f = fixture()
	f.action.start()
	f:update(100)
	f:update(-0.25)
	f:finish(true)
	close(f.moves[3], -99.75)
	close(f.windows[1].at.x, 300)
	assert(f.follow_focus)
	f.timer:fire()
	assert(not f.rule.enabled)
end)

test("edges clamp without accumulating overscroll or delaying reversal", function()
	local f = fixture()
	f.action.start()
	f:update(900)
	close(f.moves[1], 500)
	f:update(10)
	assert(#f.moves == 1)
	f:update(-2)
	close(f.moves[2], -2)
	f:update(-3000)
	close(f.moves[3], -1398)
	f:update(0.5)
	close(f.moves[4], 0.5)
	f:finish()
	assert(#f.moves == 4)
end)

test("a centered single column cannot be dragged into empty space", function()
	local f = fixture()
	f.windows = { f.windows[1] }
	f.windows[1].at.x = 800
	f.action.start()
	f:update(100)
	f:update(-100)
	assert(#f.moves == 0)
	f:finish()
end)

test("columns wider than the viewport remain reachable edge to edge", function()
	local f = fixture()
	f.windows = { f.windows[1] }
	f.windows[1].at.x = -500
	f.windows[1].size.x = 3000
	f.action.start()
	f:update(2000)
	close(f.moves[1], 500)
	f:update(-2000)
	close(f.moves[2], -1000)
	f:finish(true)
	close(f.windows[1].at.x, -500)
end)

test("logical monitor coordinates, reserved areas and gaps determine bounds", function()
	local f = fixture()
	f.monitor = {
		x = -100,
		width = 2000,
		scale = 2,
		mode = { width = 1000 },
		reserved = { left = 40, right = 100 },
	}
	f.gaps = { left = 10, right = 30 }
	f.windows = { f.windows[1], f.windows[3] }
	f.windows[1].at.x, f.windows[1].size.x = -300, 200
	f.windows[2].at.x, f.windows[2].size.x = 1000, 500
	f.action.start()
	f:update(3000)
	close(f.moves[1], 560)
	f:update(-3000)
	close(f.moves[2], -1450)
	f:finish()
end)

test("non-scrolling and empty workspaces are untouched", function()
	for _, layout in ipairs({ "dwindle", "master" }) do
		local f = fixture({ layout = layout })
		f.action.start()
		f:update(100)
		f:finish()
		assert(#f.moves == 0 and f.follow_focus and not f.rule.enabled and not f.timer)
	end
	local f = fixture()
	f.windows = {}
	f.action.start()
	f:update(100)
	f:finish()
	assert(#f.moves == 0 and f.follow_focus and not f.rule.enabled)
end)

test("hidden, floating and non-layout windows are excluded", function()
	local f = fixture()
	f.windows[1].hidden = true
	f.windows[2].floating = true
	f.windows[3].layout = nil
	f.action.start()
	f:update(100)
	assert(#f.moves == 0 and f.follow_focus and not f.rule.enabled)
end)

test("disabled follow_focus is preserved", function()
	local f = fixture({ follow_focus = false })
	f.action.start()
	f:update(10)
	f:finish()
	assert(not f.follow_focus)
	f.timer:fire()
	assert(not f.rule.enabled)
end)

test("special workspaces take precedence and scope the animation rule", function()
	local f = fixture()
	f.special_workspace = { addressable_name = "special:scratch", tiled_layout = "scrolling" }
	for _, window in ipairs(f.windows) do
		window.workspace = f.special_workspace
	end
	f.action.start()
	assert(f.rule.match.workspace == "special:scratch")
	f:update(10)
	close(f.moves[1], 10)
	f:finish()
end)

test("workspace and monitor changes stop the gesture and restore settings", function()
	for _, event in ipairs({ "workspace.active", "workspace.special_active", "monitor.focused", "monitor.removed" }) do
		local f = fixture()
		f.action.start()
		f:update(10)
		if event:match("^workspace") then
			f.workspace = { addressable_name = "2", tiled_layout = "scrolling" }
		else
			f.monitor = {}
		end
		f.listeners[event]()
		assert(f.follow_focus and not f.rule.enabled and not f.timer.enabled)
		f:update(10)
		f:finish(true)
		assert(#f.moves == 1)
	end
end)

test("layout changes are also detected without a context event", function()
	local f = fixture()
	f.action.start()
	f.workspace.tiled_layout = "dwindle"
	f:update(10)
	assert(#f.moves == 0 and f.follow_focus and not f.rule.enabled)
end)

test("config unload cleans up an active gesture and pending restoration", function()
	for _, finished in ipairs({ false, true }) do
		local f = fixture()
		f.action.start()
		f:update(10)
		if finished then
			f:finish()
		end
		f.listeners["config.unload"]()
		assert(f.follow_focus and not f.rule.enabled and not f.timer.enabled)
	end
end)

test("a new gesture disarms the previous restoration timer", function()
	local f = fixture()
	f.action.start()
	f:update(10)
	f:finish()
	assert(f.timer.enabled)
	f.action.start()
	assert(not f.timer.enabled)
	f.timer:fire()
	assert(f.rule.enabled and not f.follow_focus)
	f:update(10)
	f:finish()
	assert(f.follow_focus)
	f.timer:fire()
	assert(not f.rule.enabled)
end)

test("failed dispatches restore settings instead of leaving a gesture active", function()
	local f = fixture()
	f.action.start()
	f.fail_dispatch = true
	f:update(10)
	assert(#f.moves == 0 and f.follow_focus and not f.rule.enabled and not f.timer.enabled)
	f:finish()
end)

test("missing workspaces and monitors are harmless", function()
	for _, key in ipairs({ "workspace", "monitor" }) do
		local f = fixture()
		f[key] = nil
		f.action.start()
		f:update(10)
		f:finish()
		assert(#f.moves == 0 and f.follow_focus and not f.rule.enabled)
	end
end)

print("passed " .. count .. " scrolling gesture tests")
