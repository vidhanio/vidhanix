local waywall = require("waywall")
local helpers = require("waywall.helpers")

helpers.res_mirror({ src = eyeSrc, dst = eyeDst }, tall.w, tall.h)
helpers.res_image(files.eye_overlay, { dst = eyeDst, depth = 999 }, tall.w, tall.h)

local toggle_tall = helpers.toggle_res(tall.w, tall.h, sens.tall)

return {
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
	actions = {
		["*-F4"] = function()
			if waywall.get_key("F3") then
				return false
			end
			return toggle_tall()
		end,
		["*-Alt-B"] = helpers.toggle_res(thin.w, thin.h),
		["*-Alt-N"] = helpers.toggle_res(wide.w, wide.h),
		["*-Alt-apostrophe"] = function()
			waywall.exec(programs.ninjabrain_bot)
			waywall.show_floating(true)
		end,
		["*-Alt-semicolon"] = helpers.toggle_floating,
	},
}
