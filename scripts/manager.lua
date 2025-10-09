local M = {}

M.sound_on = true
M.current_world = 1
M.current_level = 1
M.completed_levels = 0
M.completed_worlds = 0
M.SCENES = {
	MENU = "menu",
	LEVELS = "levels",
	LEVEL = "level"
}
M.current_scene = M.SCENES.MENU

--[[
	NUEVA ESTRUCTURA DE PROGRESO:
	Esta tabla guardará todo el progreso del jugador.
	La clave de la tabla 'worlds' será el número del mundo, y su valor,
	el número de niveles completados en ese mundo.
	Ejemplo: { worlds = { [1] = 20, [2] = 5 } }
	Significa:
	- Mundo 1: 20 niveles completados (mundo terminado).
	- Mundo 2: 5 niveles completados.
	]]
	M.progress = {
		worlds = {}
	}

	return M