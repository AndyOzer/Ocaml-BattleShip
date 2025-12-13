val coord_equal : Battleship_types.coordinate -> Battleship_types.coordinate -> bool
(** Checks if two coordinates [a] and [b] are equal *)

val coord_in_list : Battleship_types.coordinate -> Battleship_types.coordinate list -> bool
(** Checks if coordinate [c] exists in the list [lst] *)

val make_cell : int -> int -> Battleship_types.cell
(** Creates a new empty cell at coordinates ([x], [y]) *)

val make_empty_board : int -> Battleship_types.board
(** Creates a new game board of [size] with all cells empty *)

val ship_contains_coordinate : Battleship_types.ship -> Battleship_types.coordinate -> bool
(** Checks if the [ship] occupies the given [coord] *)

val ship_is_sunk : Battleship_types.ship -> bool
(** Checks if all coordinates of the [ship] have been hit *)

val remove_sunk_ships : Battleship_types.board -> Battleship_types.board
(** Removes ships that have been completely sunk from the [board]'s active ships list *)