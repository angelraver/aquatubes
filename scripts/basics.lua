local B = {}

B.SCREEN_WIDTH = 640
B.SCREEN_HEIGHT = 400

B.GRID_WIDTH = 10
B.GRID_HEIGHT = 10

B.TILE_WIDTH = 64
B.TILE_HEIGHT = 32

B.GRID_PIXEL_WIDTH = (B.GRID_WIDTH + B.GRID_HEIGHT) * B.TILE_WIDTH / 2
B.GRID_PIXEL_HEIGHT = (B.GRID_WIDTH + B.GRID_HEIGHT) * B.TILE_HEIGHT / 2

B.OFFSET_X = B.SCREEN_WIDTH / 2
B.OFFSET_Y = 40

-- Posición en pantalla donde se dibuja el tile (0, 0)
B.ORIGIN_X = 128  -- este es el centro del tile 0,0 en X
B.ORIGIN_Y = 104  -- este es el centro del tile 0,0 en Y

function B.iso_to_world(iso_x, iso_y)
	local world_x = (iso_x - iso_y) * (B.TILE_WIDTH / 2) + B.ORIGIN_X
	local world_y = (iso_x + iso_y) * (B.TILE_HEIGHT / 2) + B.ORIGIN_Y
	return vmath.vector3(world_x, world_y, 0)
end

function B.screen_to_iso(screen_x, screen_y)
	-- Restar el origen del tile (0,0)
	local dx = screen_x - B.ORIGIN_X
	local dy = screen_y - B.ORIGIN_Y

	-- Calcular posición isométrica a partir del delta
	local iso_x = math.floor((dx / (B.TILE_WIDTH / 2) + dy / (B.TILE_HEIGHT / 2)) / 2)
	local iso_y = math.floor((dy / (B.TILE_HEIGHT / 2) - dx / (B.TILE_WIDTH / 2)) / 2)

	return iso_x, iso_y
end

return B
