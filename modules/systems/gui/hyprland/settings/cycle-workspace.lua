local function cycleWorkspace(direction)
	local offset = direction == "next" and 1 or -1

	local activeMonitor = hl.get_active_monitor()
	if not activeMonitor or not activeMonitor.active_workspace then
		return
	end
	local currentWorkspace = activeMonitor.active_workspace.id

	-- Skip workspaces that are currently visible on other monitors.
	local blocked = {}
	for _, monitor in ipairs(hl.get_monitors()) do
		if not monitor.focused and monitor.active_workspace and monitor.active_workspace.id > 0 then
			blocked[monitor.active_workspace.id] = true
		end
	end

	local highestOccupied = 0
	for _, workspace in ipairs(hl.get_workspaces()) do
		if workspace.id > 0 and workspace.windows > 0 and workspace.id > highestOccupied then
			highestOccupied = workspace.id
		end
	end

	-- Allow exactly one trailing empty workspace before wrapping.
	local cycleLimit = math.max(highestOccupied + 1, 1, currentWorkspace)

	-- Build the ordered cycle list and locate the current workspace within it in one pass.
	local candidates = {}
	local currentIndex = 1
	for workspace = 1, cycleLimit do
		if not blocked[workspace] then
			table.insert(candidates, workspace)
			if workspace == currentWorkspace then
				currentIndex = #candidates
			end
		end
	end

	if #candidates == 0 then
		return
	end

	local targetIndex = ((currentIndex - 1 + offset) % #candidates) + 1

	hl.dispatch(hl.dsp.focus({ workspace = candidates[targetIndex], on_current_monitor = true }))
end

hl.bind("SUPER + Tab", function()
	cycleWorkspace("next")
end)

hl.bind("SUPER + SHIFT + Tab", function()
	cycleWorkspace("prev")
end)

-- Workspace gestures bypass binds.hide_special_on_workspace_change.
hl.on("workspace.active", function(workspace)
	local monitor = workspace.monitor
	if monitor and monitor.active_special_workspace then
		monitor:set_special_workspace({})
	end
end)
