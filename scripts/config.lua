local C = {}

C.SCREEN_WIDTH = 640
C.SCREEN_HEIGHT = 780

C.GRID_WIDTH = 10
C.GRID_HEIGHT = 10

C.TILE_WIDTH = 96
C.TILE_HEIGHT = 48

C.VERTICAL_OFFSET = -120

local grid_center_y_offset = (C.GRID_HEIGHT - 1) * (C.TILE_HEIGHT / 2)
C.ORIGIN_X = C.SCREEN_WIDTH / 2 - C.TILE_WIDTH / 2
C.ORIGIN_Y = (C.SCREEN_HEIGHT / 2) - grid_center_y_offset + C.VERTICAL_OFFSET

C.BANNED_CELLS_SET = {
	["0,9"] = true,
	["1,9"] = true,
	["2,9"] = true,
	["3,9"] = true,
	["0,8"] = true,
	["1,8"] = true,
	["2,8"] = true,
	["0,7"] = true,
	["1,7"] = true,
	["0,6"] = true,
	["7,0"] = true,
	["8,0"] = true,
	["9,0"] = true,
	["8,1"] = true,
	["9,1"] = true,
	["9,2"] = true,
}

return C