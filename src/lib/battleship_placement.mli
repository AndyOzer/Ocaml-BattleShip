val generate_ship_coordinates : Battleship_types.coordinate -> Battleship_types.ship_type -> Battleship_types.ship_orientation -> Battleship_types.coordinate list
(** Calculates the list of coordinates a ship would occupy given its [start_coordinate], [ship_type], and [input_orientation] *)

val is_ship_within_bounds : Battleship_types.coordinate list -> Battleship_types.board -> bool
(** Checks if all coordinates in [coordinate_list] are within the [board] boundaries *)

val does_ship_overlap : Battleship_types.coordinate list -> Battleship_types.board -> bool
(** Checks if any of the coordinates in [coordinate_list] overlap with existing ships on the [board] *)

val is_ship_coordinate_valid : Battleship_types.coordinate -> Battleship_types.ship_type -> Battleship_types.ship_orientation -> Battleship_types.board -> bool
(** Validates if a ship with [ship_type] can be placed at [start_coordinate] with the given [input_orientation] on the [board] *)

val place_ship_on_board : Battleship_types.coordinate -> Battleship_types.ship_type -> Battleship_types.ship_orientation -> Battleship_types.board -> Battleship_types.board * string
(** Attempts to place a ship with [ship_type] on the [board], returns the updated board and message *)

val auto_place_all_ships : Battleship_types.board -> Battleship_types.board
(** Automatically places all required ships randomly on the [board] *)

val place_ship_by_index_and_coords : int -> Battleship_types.coordinate -> Battleship_types.coordinate -> Battleship_types.board -> Battleship_types.board * string
(** Places a ship determined by [index] (0=Carrier, 1=Battleship, etc.) using start and end coordinates to determine orientation *)