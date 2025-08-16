local C = require "scripts.config"
local Grid = {}

function Grid.draw_line(p1, p2)
	-- Esto dibuja una línea en pantalla
	msg.post("@render:", "draw_line", { start_point = p1, end_point = p2, color = vmath.vector4(0, 1, 0, 1) })
end

function Grid.draw_tile(x, y)
	local half_w = C.TILE_WIDTH / 2
	local half_h = C.TILE_HEIGHT / 2

	local world_x = (x - y) * half_w + C.ORIGIN_X
	local world_y = (x + y) * half_h + C.ORIGIN_Y	

	local p1 = vmath.vector3(world_x,world_y + half_h, 1) -- top
	local p2 = vmath.vector3(world_x + half_w, world_y, 1) -- right
	local p3 = vmath.vector3(world_x, world_y - half_h, 1) -- bottom
	local p4 = vmath.vector3(world_x - half_w, world_y, 1) -- left

	Grid.draw_line(p1, p2)
	Grid.draw_line(p2, p3)
	Grid.draw_line(p3, p4)
	Grid.draw_line(p4, p1)
end

function Grid.draw_grid()
	for x = 0, C.GRID_WIDTH - 1 do
		for y = 0, C.GRID_HEIGHT - 1 do
			Grid.draw_tile(x, y)
		end
	end
end

return Grid