local M = {}

M.sound_on = true
M.current_world = 1
M.current_level = 1
M.completed_levels = 0
M.completed_worlds = 0
M.SCENES = {
	MENU = "menu",
	LEVEL_SELECTOR = "level_selector",
	LEVEL = "level"
}
M.current_scene = M.SCENES.MENU

return M