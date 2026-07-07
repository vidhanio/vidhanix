-- added by mcsr-nixos
package.path = package.path .. ";/nix/store/3r8bcz23fi48rk2zvfp8gl4l5if5q99r-waywork-0-unstable-2025-11-29/?.lua"
local programs = {
	ninjabrain_bot = "/nix/store/s6pp70wijr0z2drks0ik67acm9q0yq9q-ninjabrain-bot-1.5.2/bin/ninjabrain-bot",
}
local files = {
	eye_overlay = "/home/vidhanio/Downloads/overlay (9).png",
}
-- end mcsr-nixos
--
local waywall = require("waywall")
local helpers = require("waywall.helpers")
local Scene = require("waywork.scene")
local Modes = require("waywork.modes")
local Keys = require("waywork.keys")
local Processes = require("waywork.processes")

local function center_in(child, parent)
	return {
		x = (parent.w - child.w) / 2 + (parent.x or 0),
		y = (parent.h - child.h) / 2 + (parent.y or 0),
		w = child.w,
		h = child.h,
	}
end

local sens = {
	base = 3,
	tall = 0.1,
}

local monitor = {
	w = 2560,
	h = 1440,
}

local thin = {
	w = 400,
	h = monitor.h,
}

local tall = {
	w = 384,
	h = 16384,
}

local wide = {
	w = 2560,
	h = 400,
}

local config = {
	input = {
		sensitivity = sens.base,
	},
	theme = {
		ninb_anchor = "topright",
		ninb_opacity = 1,
	},
}

local scene = Scene.SceneManager.new(waywall)

local eye_src = {
	w = 60,
	h = 1320,
}

local eye = {
	w = 872,
	h = 1080,
}

local eye_dst = center_in(eye, { w = (monitor.w - tall.w) / 2, h = monitor.h })

scene:register("eye_measure", {
	kind = "mirror",
	options = { src = center_in(eye_src, tall), dst = eye_dst },
	groups = { "tall" },
})

scene:register("eye_overlay", {
	kind = "image",
	path = files.eye_overlay,
	options = { dst = eye_dst, depth = 999 },
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
