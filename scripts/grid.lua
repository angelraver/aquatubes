local B = require "scripts.basics"
local Grid = {}

function Grid.draw_line(p1, p2)
	-- Esto dibuja una línea en pantalla
	msg.post("@render:", "draw_line", { start_point = p1, end_point = p2, color = vmath.vector4(0, 1, 0, 1) })
end

function Grid.draw_tile(x, y)
	local half_w = B.TILE_WIDTH / 2
	local half_h = B.TILE_HEIGHT / 2

	local world_x = (x - y) * half_w + B.OFFSET_X
	local world_y = (x + y) * half_h + B.OFFSET_Y
	
	B.ORIGIN_X = 128  -- este es el centro del tile 0,0 en X
	B.ORIGIN_Y = 104  -- este es el centro del tile 0,0 en Y
	

	local p1 = vmath.vector3(world_x,world_y + half_h, 0) -- top
	local p2 = vmath.vector3(world_x + half_w, world_y, 0) -- right
	local p3 = vmath.vector3(world_x, world_y - half_h, 0) -- bottom
	local p4 = vmath.vector3(world_x - half_w, world_y, 0) -- left

	Grid.draw_line(p1, p2)
	Grid.draw_line(p2, p3)
	Grid.draw_line(p3, p4)
	Grid.draw_line(p4, p1)
end

function Grid.drawGrid()
	for x = 0, B.GRID_WIDTH - 1 do
		for y = 0, B.GRID_HEIGHT - 1 do
			Grid.draw_tile(x, y)
		end
	end
end

function Grid.create_cell_table() 
	local cells = {}
	for x = 0, B.GRID_WIDTH - 1 do
		cells[x] = {}
		for y = 0, B.GRID_HEIGHT - 1 do
			local label = string.char(65 + x) .. tostring(y + 1)
			cells[x][y] = {
				id = label,
				value = nil
			}
		end
	end

	return cells
end

return Grid