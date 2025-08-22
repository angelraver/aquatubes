local M = {}

M.sound_on = true
M.current_world = 1
M.current_level = 1
M.SCENES = {
	MENU = "menu",
	LEVEL_GRID = "level_grid",
	LEVEL = "level"
}
M.current_scene = M.SCENES.MENU
M.world_1 =  {
	{ l = 1, open = true, done = false },
	{ l = 2, open = false, done = false },
	{ l = 3, open = false, done = false },
	{ l = 4, open = false, done = false },
	{ l = 5, open = false, done = false },
	{ l = 6, open = false, done = false },
	{ l = 7, open = false, done = false },
	{ l = 8, open = false, done = false },
	{ l = 9, open = false, done = false },
	{ l = 10, open = false, done = false },
	{ l = 11, open = false, done = false },
	{ l = 12, open = false, done = false },
	{ l = 13, open = false, done = false },
	{ l = 14, open = false, done = false },
	{ l = 15, open = false, done = false }
}

function M.complete_level()
  local next_level_to_open = M.current_level + 1
  for i, level_data in ipairs(M["world_" .. M.current_world]) do
    if level_data.l == M.current_level then-- encontramos el nivel que se completó, lo marcamos como 'done = true'
      level_data.done = true
    end

    if level_data.l == next_level_to_open then-- si encontramos el siguiente nivel, lo marcamos como 'open = true'
      level_data.open = true
    end
	end
end

return M