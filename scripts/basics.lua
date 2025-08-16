local C = require "scripts.config"
local B = {}

function B.iso_to_world(iso_x, iso_y, z)
	local _z = z or 0
	local world_x = (iso_x - iso_y) * (C.TILE_WIDTH / 2) + C.ORIGIN_X
	local world_y = (iso_x + iso_y) * (C.TILE_HEIGHT / 2) + C.ORIGIN_Y
	return vmath.vector3(world_x, world_y, _z)
end

function B.screen_to_iso(screen_x, screen_y)
	local half_w = C.TILE_WIDTH / 2
	local half_h = C.TILE_HEIGHT / 2

	local dx = screen_x - C.ORIGIN_X
	local dy = screen_y - C.ORIGIN_Y

	local iso_x_float = (dx / half_w + dy / half_h) / 2
	local iso_y_float = (dy / half_h - dx / half_w) / 2

	local candidate_x = math.floor(iso_x_float + 0.5)
	local candidate_y = math.floor(iso_y_float + 0.5)

	local tile_center_world = B.iso_to_world(candidate_x, candidate_y)

	local diff_x = math.abs(screen_x - tile_center_world.x)
	local diff_y = math.abs(screen_y - tile_center_world.y)

	if (diff_x / half_w + diff_y / half_h) <= 1.0 then
		if candidate_x >= 0 and candidate_x < C.GRID_WIDTH and
		candidate_y >= 0 and candidate_y < C.GRID_HEIGHT then
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

function B.check_level_complete(level_pipes_table, board_pipes_table )
	if #board_pipes_table > 0 then
		local errors = 0
		for _, cell in ipairs(level_pipes_table) do
			local good_pipe = B.get_cell_by_coords(board_pipes_table, cell.x, cell.y)
			if not good_pipe then
				errors = errors + 1
			end
		end
		return errors == 0
	else
		return false
	end
end

-- @description Genera una lista de tuberías en posiciones aleatorias,
-- evitando las celdas prohibidas y sin repetir posiciones.
-- @param level_table La tabla de nivel que define cuántas tuberías y de qué tipo crear.
-- @return Una nueva tabla con las tuberías en posiciones aleatorias válidas.
function B.get_random_pipes(level_table)
	local random_pipes = {}
	local occupied_cells = {}
	for key, value in pairs(C.BANNED_CELLS_SET) do
		occupied_cells[key] = value
	end
	-- Ahora, iteramos sobre el nivel para crear cada tubería aleatoria.
	for _, cell_info in ipairs(level_table) do
		local random_x, random_y
		local key
		-- Buscamos una celda aleatoria que NO esté ocupada.
		-- El bucle se repetirá hasta que encuentre una celda válida.
		repeat
			random_x = B.get_random_number(0, 8)
			random_y = B.get_random_number(0, 8)
			key = random_x .. "," .. random_y
		until not occupied_cells[key]
		-- Una vez encontrada una celda válida, la marcamos como ocupada
		-- para evitar que futuras tuberías en esta misma llamada usen esta celda (evita repetidos).
		occupied_cells[key] = true
		-- Creamos la nueva tubería y la añadimos a la tabla de resultados.
		local random_cell = {
			x = random_x,
			y = random_y,
			pipe_type = cell_info.pipe_type
		}
		table.insert(random_pipes, random_cell)
	end

	return random_pipes
end

function B.place_random_pipes(level_table)
	local random_pipes = B.get_random_pipes(level_table)
	local random_placed_pipes = {}
	for i, cell in ipairs(random_pipes) do
		local cell_to_save = B.place_pipe(cell.pipe_type, cell.x, cell.y)
		table.insert(random_placed_pipes, cell_to_save)
	end
	return random_placed_pipes
end

function B.place_pipe(pipe_type, iso_x, iso_y)
	local z = B.get_z_for_cell(iso_x)
	local world_pos_with_z = B.iso_to_world(iso_x, iso_y, z)
	local pipe_id = factory.create("#" .. pipe_type .. "_factory", world_pos_with_z)
	local cell_to_save = {
		id = pipe_id,
		pipe_type = pipe_type,
		x = iso_x,
		y = iso_y
	}
	return cell_to_save
end

function B.get_random_number(min_num, max_num)
	if min_num > max_num then
		min_num, max_num = max_num, min_num
	end
	return math.random(min_num, max_num)
end

function B.get_z_for_cell(iso_x)
	if iso_x < 9 then
		return 1 - (iso_x / 10) - 0.1
	else
		return 1 - (iso_x / 10)
	end
end

return B
