open Battleship_types
open Battleship_helper

val generate_ship_coordinates : Battleship_types.coordinate -> Battleship_types.ship_type -> Battleship_types.orientation -> Battleship_types.coordinate list

val is_ship_within_bounds : Battleship_types.coordinate list -> Battleship_types.board -> bool

val does_ship_overlap : Battleship_types.coordinate list -> Battleship_types.board -> bool

val is_ship_coordinate_valid : Battleship_types.coordinate -> Battleship_types.ship_type -> Battleship_types.orientation -> Battleship_types.board -> bool

val place_ship_on_board : Battleship_types.coordinate -> Battleship_types.ship_type -> Battleship_types.orientation -> Battleship_types.board -> Battleship_types.board * string

val auto_place_all_ships : Battleship_types.board -> Battleship_types.board