open Battleship_types

let coord_equal (a:coordinate) (b:coordinate) : bool =
	a.x_coordinate = b.x_coordinate && a.y_coordinate = b.y_coordinate

let coord_in_list (c:coordinate) (lst:coordinate list) : bool = List.exists (fun x -> coord_equal x c) lst

let make_cell (x:int) (y:int) : Battleship_types.cell = { coordinate = { x_coordinate = x; y_coordinate = y }; cell_type = Empty }

let make_empty_board (size:int) : Battleship_types.board =
	let coords =
		List.init (size * size) (fun i ->
				let x = (i mod size) + 1 in
				let y = (i / size) + 1 in
				make_cell x y)
	in
	{ board_size = size; battleship_board = coords; ships = [] }

let ship_contains_coordinate ship coord =
	ship.coordinates |> List.exists (fun x -> coord_equal x coord)

let ship_is_sunk ship =
	ship.coordinates |> List.for_all (fun c -> coord_in_list c ship.hits)

let remove_sunk_ships (board: Battleship_types.board) : Battleship_types.board =
	board.ships
	|> List.partition ship_is_sunk
	|> snd
	|> fun alive -> { board with ships = alive }