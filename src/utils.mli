open Types

val in_bounds : coord -> bool

val range : int -> int -> int list

val letters : char list

val coord_of_string : string -> coord option

val string_of_coord : coord -> string

val empty_board : board

val cell_to_char : cell -> char

val print_board : ?show_ships:bool -> board -> unit
