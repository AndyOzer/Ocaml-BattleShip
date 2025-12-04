type coordinate = {
	x_coordinate : int;
	y_coordinate : int;
}

type ship_type = Carrier | Battleship | Cruiser | Submarine | Destroyer

type orientation = Horizontal | Vertical

type board_cell_type = Empty | ShipPart of ship_type | Hit | Miss

type cell = {
	coordinate : coordinate;
	cell_type : board_cell_type;
}

let ship_size = function
	| Carrier -> 5
	| Battleship -> 4
	| Cruiser -> 3
	| Submarine -> 3
	| Destroyer -> 2

type ship_orientation = Horizontal | Vertical

type ship = {
	battleship_type : ship_type;
	orientation : ship_orientation;
	coordinates : coordinate list;
	hits : coordinate list;
}

type board ={
	board_size : int;
	battleship_board : cell list;
	ships : ship list;
}
