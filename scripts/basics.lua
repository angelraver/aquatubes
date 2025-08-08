local B = {}

B.SCREEN_WIDTH = 640
B.SCREEN_HEIGHT = 400

B.GRID_WIDTH = 10
B.GRID_HEIGHT = 10

B.TILE_WIDTH = 64
B.TILE_HEIGHT = 32

-- Variable para ajustar el espacio vertical.
-- Un valor positivo mueve la grilla hacia abajo.
-- Un valor negativo mueve la grilla hacia arriba.
B.VERTICAL_OFFSET = 0

-- Calculamos el origen de la cuadrícula dinámicamente para que
-- el centro del tablero esté en el centro de la pantalla.
-- El origen (B.ORIGIN_X, B.ORIGIN_Y) es el centro del tile (0, 0).
-- El ancho total de la cuadrícula es de (B.GRID_WIDTH + B.GRID_HEIGHT) * B.TILE_WIDTH / 2.
-- La altura total de la cuadrícula es de (B.GRID_WIDTH + B.GRID_HEIGHT) * B.TILE_HEIGHT / 2.
-- No, esta fórmula es incorrecta para el tamaño real del rombo de la grilla.
-- El ancho real de la grilla isométrica es (B.GRID_WIDTH + B.GRID_HEIGHT) * B.TILE_WIDTH / 2,
-- y la altura es (B.GRID_WIDTH + B.GRID_HEIGHT) * B.TILE_HEIGHT / 2.
-- Para una grilla de 10x10, la distancia entre el centro de la celda (0,0) y el centro
-- de la celda (9,9) es (9+9) * B.TILE_HEIGHT/2.
-- Por lo tanto, el centro vertical de la grilla es a la mitad de esa distancia.
local grid_center_y_offset = (B.GRID_HEIGHT - 1) * (B.TILE_HEIGHT / 2)
B.ORIGIN_X = B.SCREEN_WIDTH / 2
B.ORIGIN_Y = (B.SCREEN_HEIGHT / 2) - grid_center_y_offset + B.VERTICAL_OFFSET

function B.iso_to_world(iso_x, iso_y, z)
	local _z = z or 0
	local world_x = (iso_x - iso_y) * (B.TILE_WIDTH / 2) + B.ORIGIN_X
	local world_y = (iso_x + iso_y) * (B.TILE_HEIGHT / 2) + B.ORIGIN_Y
	return vmath.vector3(world_x, world_y, _z)
end

function B.screen_to_iso(screen_x, screen_y)
	local half_w = B.TILE_WIDTH / 2
	local half_h = B.TILE_HEIGHT / 2

	local dx = screen_x - B.ORIGIN_X
	local dy = screen_y - B.ORIGIN_Y

	local iso_x_float = (dx / half_w + dy / half_h) / 2
	local iso_y_float = (dy / half_h - dx / half_w) / 2

	local candidate_x = math.floor(iso_x_float + 0.5)
	local candidate_y = math.floor(iso_y_float + 0.5)

	local tile_center_world = B.iso_to_world(candidate_x, candidate_y)

	local diff_x = math.abs(screen_x - tile_center_world.x)
	local diff_y = math.abs(screen_y - tile_center_world.y)

	if (diff_x / half_w + diff_y / half_h) <= 1.0 then
		if candidate_x >= 0 and candidate_x < B.GRID_WIDTH and
		candidate_y >= 0 and candidate_y < B.GRID_HEIGHT then
			return candidate_x, candidate_y
		end
	end

	return nil, nil
end

function B.get_cell_by_coords(current_table, x, y)
	for _, cell in ipairs(current_table) do
		if cell.x == x and cell.y == y then
			return cell
		end
	end
	return nil  -- si no se encuentra
end

function B.delete_cell_by_coords(current_table, x, y)
	for i, cell in ipairs(current_table) do
		if cell.x == x and cell.y == y then
			table.remove(current_table, i)
			break
		end
	end
end

function B.check_level_complete(level_pipes_table, player_pipes_table )
	if #player_pipes_table > 0 then
		local errors = 0
		for _, cell in ipairs(level_pipes_table) do
			local good_pipe = B.get_cell_by_coords(player_pipes_table, cell.x, cell.y)
			if not good_pipe then
				errors = errors + 1
			end
		end
		return errors == 0
	else
		return false
	end
end

return B
