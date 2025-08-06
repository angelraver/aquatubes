local B = require "scripts.basics"
local Grid = require "scripts.grid"

local Levels = {}

function Levels.level_1()
	local cells = Grid.create_cell_table() 
	cells[0][4].value = "p1"
	cells[1][4].value = "p1"
	cells[2][4].value = "p1"
	cells[3][4].value = "p1"
	cells[4][4].value = "p1"
	cells[5][4].value = "p1"
	cells[6][4].value = "p1"
	cells[7][4].value = "p1"
	cells[8][4].value = "p1"
	return cells
end

return Levels