open Types

val make_ship : ship_kind -> coord -> orientation -> ship
(* Creates a ship of the given kind at the given coordinate and orientation *)

val overlaps : ship -> ship -> bool
(* Returns true if the two ships overlap on any coordinates *)

val contains_coord : ship -> coord -> bool
(* Returns true if the ship occupies the given coordinate *)

val string_of_ship_kind : ship_kind -> string
(* Returns the string representation of the ship kind *)

val ship_cells : ship -> (coord * cell) list
(* Returns a list of (coordinate, cell) pairs for the ship's occupied coordinates *)
