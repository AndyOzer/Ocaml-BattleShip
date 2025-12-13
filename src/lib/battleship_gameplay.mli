val fire_at_coordinate : Battleship_types.coordinate -> Battleship_types.board -> Battleship_types.board * string
(** Processes a shot at the given [target_coordinate] on the [board], returns updated board and a message indicating the result *)

val check_if_game_over : Battleship_types.board -> bool
(** Checks if all ships on the [board] have been sunk *)