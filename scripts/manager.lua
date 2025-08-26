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
	{ l = 15, open = false, done = false },
	{ l = 16, open = false, done = false },
	{ l = 17, open = false, done = false },
	{ l = 18, open = false, done = false },
	{ l = 19, open = false, done = false },
	{ l = 20, open = false, done = false }
}

function M.refresh_levels()
  for i, level_data in ipairs(M["world_" .. M.current_world]) do
    if level_data.l < M.current_level then-- todos los niveles anteriores al current_level estan open y done
      level_data.open = true
			level_data.done = true
    end
    if level_data.l == M.current_level then -- el current_level está en open
      level_data.open = true
    end
	end
end

function M.complete_level()
	M.current_level = M.current_level + 1
	msg.post("main:/progress_manager", "level_completed", { world = M.current_world, level = M.current_level })
	M.refresh_levels()
end


return M