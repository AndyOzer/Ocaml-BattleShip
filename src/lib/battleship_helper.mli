

val coord_equal : Battleship_types.coordinate -> Battleship_types.coordinate -> bool

val coord_in_list : Battleship_types.coordinate -> Battleship_types.coordinate list -> bool

val make_cell : x:int -> y:int -> Battleship_types.cell

val make_empty_board : int -> Battleship_types.board

val ship_contains_coordinate : Battleship_types.ship -> Battleship_types.coordinate -> bool

val ship_is_sunk : Battleship_types.ship -> bool

val remove_sunk_ships : Battleship_types.board -> Battleship_types.board
