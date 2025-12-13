type coordinate = {
  x_coordinate : int;
  y_coordinate : int;
} [@@deriving sexp]
(** Represents a 2D coordinate on the board *)

type ship_type = Carrier | Battleship | Cruiser | Submarine | Destroyer [@@deriving sexp]
(** Represents the different types of ships available in the game *)

type board_cell_type = Empty | ShipPart of ship_type | Hit | Miss [@@deriving sexp]
(** Represents the state of a single cell on the board *)

type cell = {
  coordinate : coordinate;
  cell_type : board_cell_type;
} [@@deriving sexp]
(** Represents a cell on the board with its coordinate and current state *)

val ship_size : ship_type -> int
(** Returns the length of the given [ship_type] *)

type ship_orientation = Horizontal | Vertical [@@deriving sexp]
(** Represents the orientation of a ship *)

type ship = {
  battleship_type : ship_type;
  orientation : ship_orientation;
  coordinates : coordinate list;
  hits : coordinate list;
} [@@deriving sexp]
(** Represents a ship object with its type, orientation, position, and hit status *)

type board ={
  board_size : int;
  battleship_board : cell list;
  ships : ship list;
} [@@deriving sexp]
(** Represents the game board containing all cells and ships *)