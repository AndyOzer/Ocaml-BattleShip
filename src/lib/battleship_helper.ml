open Battleship_types

let coord_equal a b =
	a.x_coordinate = b.x_coordinate && a.y_coordinate = b.y_coordinate

let coord_in_list c lst = List.exists (fun x -> coord_equal x c) lst

let make_cell ~x ~y = { coordinate = { x_coordinate = x; y_coordinate = y }; cell_type = Empty }

let make_empty_board size =
	let coords =
		List.init (size * size) (fun i ->
				let x = (i mod size) + 1 in
				let y = (i / size) + 1 in
				make_cell ~x ~y)
	in
	{ board_size = size; battleship_board = coords; ships = [] }

let ship_contains_coordinate ship coord = coord_in_list coord ship.coordinates

let ship_is_sunk ship = List.for_all (fun c -> coord_in_list c ship.hits) ship.coordinates

let remove_sunk_ships (board: Battleship_types.board) : Battleship_types.board =
	let (_sunk, alive) = List.partition ship_is_sunk board.ships in
	{ board_size = board.board_size; battleship_board = board.battleship_board; ships = alive }