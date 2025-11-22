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

function B.screen_to_iso_edit(screen_x, screen_y)
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
		if candidate_x >= 0 and candidate_x < C.GRID_WIDTH_EDIT and
		candidate_y >= 0 and candidate_y < C.GRID_HEIGHT_EDIT then
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

function B.check_level_completed(level_pipes_table, board_pipes_table )
	--print("..................................")
	local errors = 0
	for _, cell in ipairs(level_pipes_table) do
		local board_pipe = B.get_cell_by_coords(board_pipes_table, cell.x, cell.y)
		if board_pipe then
			if (board_pipe.t ~= cell.t) then 
				--print(board_pipe.t, cell.x, cell.y)
				errors = errors + 1
			end
		else
			--print("falta ", cell.x, cell.y)
			errors = errors + 1
		end
	end
	return errors == 0
end

-- @description Genera una lista de tuberías, colocando algunas en posiciones aleatorias.
-- Evita las celdas prohibidas y las posiciones de celdas con t > 20.
-- Las celdas con t > 20 mantienen su posición original y no son aleatorias.
-- @param level_table La tabla de nivel que define cuántas tuberías y de qué tipo crear.
-- @return Una nueva tabla con las tuberías en posiciones válidas (aleatorias y fijas).
function B.get_random_pipes(level_table)
	local random_pipes = {}
	local occupied_cells = {}
	-- 1. Inicializamos las celdas ocupadas con las celdas prohibidas por defecto.
	for key, value in pairs(C.BANNED_CELLS_SET) do
		occupied_cells[key] = value
	end
	-- Creamos una lista temporal para las celdas que sí necesitan una posición aleatoria.
	local cells_to_randomize = {}
	-- 2. PRIMERA PASADA:
	-- Separamos las celdas fijas (t > 20) de las que necesitan una posición aleatoria.
	-- Las celdas fijas se añaden directamente al resultado y sus posiciones se marcan como ocupadas.
	for _, cell_info in ipairs(level_table) do
		if cell_info.t > 20 then
			-- Esta celda es fija. Su posición no puede ser usada por otras.
			local key = cell_info.x .. "," .. cell_info.y
			occupied_cells[key] = true
			-- La añadimos directamente a la tabla de resultados sin modificarla.
			table.insert(random_pipes, cell_info)
		else
			-- Esta celda necesita una posición aleatoria. La guardamos para después.
			table.insert(cells_to_randomize, cell_info)
		end
	end

	-- 3. SEGUNDA PASADA:
	-- Ahora, iteramos sobre las celdas que necesitan una posición aleatoria para asignársela.
	for _, cell_info in ipairs(cells_to_randomize) do
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
		-- para evitar que futuras tuberías usen esta celda.
		occupied_cells[key] = true

		-- Creamos la nueva tubería y la añadimos a la tabla de resultados.
		-- Se mantiene la lógica original para el caso de t < 12.
		local x = cell_info.t < 12 and random_x or cell_info.x
		local y = cell_info.t < 12 and random_y or cell_info.y

		local random_cell = {
			x = x,
			y = y,
			t = cell_info.t
		}
		table.insert(random_pipes, random_cell)
	end

	return random_pipes
end

function B.place_random_pipes(level_table)
	local random_pipes = B.get_random_pipes(level_table)
	local random_placed_pipes = {}
	local retraso_actual = 0
	local incremento_retraso = 0.1 -- Cada pipe caerá 0.1 segundos después del anterior

	for i, cell in ipairs(random_pipes) do
		local pipe_id
		if(cell.t < 12 or cell.t > 100) then -- solo las pipes fijas o random van a caer y rebotar
			pipe_id = B.bounce_pipe(cell.t, cell.x, cell.y, retraso_actual)
			retraso_actual = retraso_actual + incremento_retraso
		else
			pipe_id = B.place_pipe(cell.t, cell.x, cell.y)
		end

		local cell_to_save = {
			id = pipe_id,
			t = cell.t,
			x = cell.x,
			y = cell.y
		}
		table.insert(random_placed_pipes, cell_to_save)
	end
	return random_placed_pipes
end

function B.place_pipe(t, iso_x, iso_y)
	local z = B.get_z_for_cell(iso_x, iso_y)
	local world_pos_with_z = B.iso_to_world(iso_x, iso_y, z)
	local pipe_id = factory.create("#pipe_" .. t .. "_factory", world_pos_with_z)
	local cell_to_save = {
		id = pipe_id,
		t = t,
		x = iso_x,
		y = iso_y
	}
	return cell_to_save
end


function B.bounce_pipe(t, iso_x, iso_y, delay)
	delay = delay or 0 --- <<<
	local z = B.get_z_for_cell(iso_x, iso_y)
	local final_pos = B.iso_to_world(iso_x, iso_y, z)
	local start_pos = vmath.vector3(final_pos.x, final_pos.y + 800, final_pos.z)
	local pipe_id = factory.create("#pipe_" .. t .. "_factory", start_pos)
	local fall_duration = 1 -- Duración de la caída en segundos
	local bounce_height = 50  -- Cuán alto será el rebote (en píxeles)
	local bounce_speed = 0.2  -- Duración de cada fase del rebote
	go.animate(pipe_id, "position.y", go.PLAYBACK_ONCE_FORWARD, final_pos.y, go.EASING_INEXPO, fall_duration, delay,
		function()
			sound.play("/sound_controller#clac_1")
			go.animate(pipe_id, "position.y", go.PLAYBACK_ONCE_FORWARD, final_pos.y - bounce_height, go.EASING_OUTSINE, bounce_speed, 0,
				function()
					go.animate(pipe_id, "position.y", go.PLAYBACK_ONCE_FORWARD, final_pos.y + bounce_height / 3, go.EASING_INOUTSINE, bounce_speed * 1.5, 0,
						function()
							go.animate(pipe_id, "position.y", go.PLAYBACK_ONCE_FORWARD, final_pos.y, go.EASING_INQUAD, bounce_speed, 0)
						end
					)
				end
			)
		end
	)

	return pipe_id
end

function B.place_pipes(level_table)
	local placed_pipes = {}
	for i, cell in ipairs(level_table) do
		local pipe_id = B.place_pipe(cell.t, cell.x, cell.y)
		local cell_to_save = {
			id = pipe_id,
			t = cell.t,
			x = cell.x,
			y = cell.y
		}
		table.insert(placed_pipes, cell_to_save)
	end
	return placed_pipes
end

function B.delete_all_pipes(board_table)
	for i, cell in ipairs(board_table) do
		--if cell.id ~= nil and go.exists(cell.id) then
		if cell.id ~= nil then
			go.delete(cell.id)
		end
	end
end

function B.get_random_number(min_num, max_num)
	if min_num > max_num then
		min_num, max_num = max_num, min_num
	end
	return math.random(min_num, max_num)
end

function B.get_z_for_cell(iso_x, iso_y)
	local x_z = 0.5 - (iso_x / 100) - 0.01
	local y_z = 0.5 - (iso_y / 100) - 0.01
	local z = x_z + y_z
	return z
end

function B.factory_pipe(t)
	return factory.create("#pipe_".. t .."_factory", vmath.vector3(0))
end

return B
