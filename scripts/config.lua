local C = {}
-- Calcula la altura isométrica requerida para un ángulo de 30 grados,
-- dado un ancho de celda específico.
-- @param tile_width El ancho de la celda isométrica.
-- @return El alto correspondiente para mantener una perspectiva de 30 grados.
function calculate_iso_height_for_30_degrees(tile_width)
	-- La relación para un ángulo de 30° es que la altura es el ancho dividido por la raíz cuadrada de 3.
	-- tan(30°) = altura / ancho  =>  altura = ancho * tan(30°)  =>  altura = ancho / sqrt(3)
	return tile_width / math.sqrt(3)
end

-- Versión de la función que redondea el resultado al entero más cercano.
-- Esto es útil para evitar sub-píxeles y alinear todo a una grilla de píxeles.
-- @param tile_width El ancho de la celda isométrica.
-- @return El alto redondeado al entero más cercano.
function calculate_iso_height_rounded(tile_width)
	local exact_height = calculate_iso_height_for_30_degrees(tile_width)
	-- math.floor(x + 0.5) es una forma estándar en Lua de redondear al entero más cercano.
	return math.floor(exact_height + 0.5)
end

C.SCREEN_WIDTH = 600
C.SCREEN_HEIGHT = 900

C.GRID_WIDTH = 9
C.GRID_HEIGHT = 9

C.GRID_WIDTH_EDIT = 20
C.GRID_HEIGHT_EDIT = 20

C.TILE_WIDTH = 100
C.TILE_HEIGHT = calculate_iso_height_rounded(C.TILE_WIDTH)

C.VERTICAL_OFFSET = 0
C.HORIZONTAL_OFFSET = 50

local grid_center_y_offset = (C.GRID_HEIGHT - 1) * (C.TILE_HEIGHT / 2)
C.ORIGIN_X = C.SCREEN_WIDTH / 2 - C.TILE_WIDTH / 2 + C.HORIZONTAL_OFFSET
C.ORIGIN_Y = (C.SCREEN_HEIGHT / 2) - grid_center_y_offset + C.VERTICAL_OFFSET

C.BANNED_CELLS_SET = {
	["0,4"] = true,
	["0,5"] = true,
	["0,8"] = true,
	["1,8"] = true,
	["2,8"] = true,
	["1,7"] = true,
	["0,7"] = true,
	["0,6"] = true,
	["8,2"] = true,
	["8,1"] = true,
	["8,0"] = true,
	["7,1"] = true,
	["7,0"] = true,
	["6,0"] = true,
}

C.WORLD_COUNT = 6
C.LEVEL_COUNT = 20

return C