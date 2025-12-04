open Battleship_types
open Battleship_helper

val fire_at_coordinate : Battleship_types.coordinate -> Battleship_types.board -> Battleship_types.board * string

val check_if_game_over : Battleship_types.board -> bool

