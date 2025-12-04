type coordinate = {
  x_coordinate : int;
  y_coordinate : int;
}

type ship_type = Carrier | Battleship | Cruiser | Submarine | Destroyer

type orientation = Horizontal | Vertical

type board_cell_type = Empty | ShipPart of ship_type | Hit | Miss

type cell = {
  coordinate : coordinate;
  cell_type : board_cell_type;
}

val ship_size : ship_type -> int

type ship_orientation = Horizontal | Vertical

type ship = {
  battleship_type : ship_type;
  orientation : ship_orientation;
  coordinates : coordinate list;
  hits : coordinate list;
}

type board ={
  board_size : int;
  battleship_board : cell list;
  ships : ship list;
}



