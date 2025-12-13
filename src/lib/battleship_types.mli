type coordinate = {
  x_coordinate : int;
  y_coordinate : int;
} [@@deriving sexp, compare, equal]

type ship_type = Carrier | Battleship | Cruiser | Submarine | Destroyer [@@deriving sexp, compare, equal]

type board_cell_type = Empty | ShipPart of ship_type | Hit | Miss [@@deriving sexp, compare, equal]

type cell = {
  coordinate : coordinate;
  cell_type : board_cell_type;
} [@@deriving sexp, compare, equal]

val ship_size : ship_type -> int

type ship_orientation = Horizontal | Vertical [@@deriving sexp, compare, equal]

type ship = {
  battleship_type : ship_type;
  orientation : ship_orientation;
  coordinates : coordinate list;
  hits : coordinate list;
} [@@deriving sexp, compare, equal]

type board ={
  board_size : int;
  battleship_board : cell list;
  ships : ship list;
} [@@deriving sexp, compare, equal]