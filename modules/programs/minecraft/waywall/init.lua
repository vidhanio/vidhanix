local waywall = require("waywall")
local helpers = require("waywall.helpers")
local Scene = require("waywork.scene")
local Modes = require("waywork.modes")
local Keys = require("waywork.keys")
local Processes = require("waywork.processes")

local config = {
	input = {
		sensitivity = sens.base,
		remaps = {
			["MB5"] = "F3",
			["MB4"] = "F5",
		},
	},
	theme = {
		ninb_anchor = "topright",
		ninb_opacity = 1,
	},
}

local scene = Scene.SceneManager.new(waywall)

scene:register("eye_measure", {
	kind = "mirror",
	options = { src = eyeSrc, dst = eyeDst },
	groups = { "tall" },
})

scene:register("eye_overlay", {
	kind = "image",
	path = files.eye_overlay,
	options = { dst = eyeDst, depth = 999 },
	groups = { "tall" },
})

local mode_manager = Modes.ModeManager.new(waywall)

mode_manager:define("thin", {
	width = thin.w,
	height = thin.h,
	on_enter = function()
		scene:enable_group("thin", true)
	end,
	on_exit = function()
		scene:enable_group("thin", false)
	end,
})

mode_manager:define("tall", {
	width = tall.w,
	height = tall.h,
	on_enter = function()
		scene:enable_group("tall", true)
		waywall.set_sensitivity(sens.tall)
	end,
	on_exit = function()
		scene:enable_group("tall", false)
		waywall.set_sensitivity(0)
	end,
})

mode_manager:define("wide", {
	width = wide.w,
	height = wide.h,
})

local actions = Keys.actions({
	["*-Alt_L"] = function()
		return mode_manager:toggle("thin")
	end,

	["*-F4"] = function()
		if not waywall.get_key("F3") then
			return mode_manager:toggle("tall")
		else
			return false
		end
	end,

	["*-Shift-V"] = function()
		return mode_manager:toggle("wide")
	end,

	["*-apostrophe"] = function()
		waywall.exec(programs.ninjabrain_bot)
		waywall.show_floating(true)
	end,
	["*-semicolon"] = function()
		helpers.toggle_floating()
	end,
})

config.actions = actions

return config
