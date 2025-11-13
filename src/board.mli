open Types

val insert_cells : board -> (coord * cell) list -> board
(* Inserts multiple cells into the board at the specified coordinates *)

val place_ship_if_free : board -> ship list -> ship -> (board * ship list) option
(* Places a ship on the board if it does not overlap with existing ships.
   Returns the updated board and ship list wrapped in Some, or None if placement fails. *)

val place_ships_auto : unit -> board * ship list
(* Automatically places all ships on a new board and returns the board and ship list *)

val find_ship_by_coord : ship list -> coord -> ship option

val fire_at : board -> ship list -> coord -> (board * ship list * shot_result)
(* Fires at the given coordinate on the board.
   Returns the updated board, ship list, and the result of the shot. *)
