open Core

type coordinate = {
  x_coordinate : int;
  y_coordinate : int;
} [@@deriving sexp]

type ship_type = Carrier | Battleship | Cruiser | Submarine | Destroyer [@@deriving sexp]

type board_cell_type = Empty | ShipPart of ship_type | Hit | Miss [@@deriving sexp]

type cell = {
  coordinate : coordinate;
  cell_type : board_cell_type;
} [@@deriving sexp]

let ship_size = function
  | Carrier -> 5
  | Battleship -> 4
  | Cruiser -> 3
  | Submarine -> 3
  | Destroyer -> 2

type ship_orientation = Horizontal | Vertical [@@deriving sexp]

type ship = {
  battleship_type : ship_type;
  orientation : ship_orientation;
  coordinates : coordinate list;
  hits : coordinate list;
} [@@deriving sexp]

type board ={
  board_size : int;
  battleship_board : cell list;
  ships : ship list;
} [@@deriving sexp]