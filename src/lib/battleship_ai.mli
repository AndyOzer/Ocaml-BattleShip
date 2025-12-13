val easy_next_fire_coordinate : Battleship_types.board -> Battleship_types.coordinate
(** Generates coordinate to fire for Easy diff, randomly pick target *)

val medium_next_fire_coordinate : Battleship_types.board -> Battleship_types.coordinate
(** Generates coordinate to fire for Medium diff, hunts adjacent cells if a ship was hit *)

val optimal_next_fire_coordinate : Battleship_types.board -> Battleship_types.coordinate
(** Generates coordinate to fire for Optimal diff, cheating mode with knowledge of ship locations *)

val hard_next_fire_coordinate : Battleship_types.board -> Battleship_types.coordinate
(** Generates coordinate to fire for Hard diff, uses probability density functions to determine likely ship location *)