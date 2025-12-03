type coord = int * int

type orientation = Horizontal | Vertical

type ship_kind =
  | Carrier
  | Battleship 
  | Cruiser    
  | Submarine  
  | Destroyer  

let ship_size = function
  | Carrier -> 5
  | Battleship -> 4
  | Cruiser -> 3
  | Submarine -> 3
  | Destroyer -> 2

type ship = {
  kind : ship_kind;
  coords : coord list;
}

type cell =
  | Empty
  | Ship of ship_kind
  | Miss
  | Hit of ship_kind

module Coord = struct
  type t = coord
  let compare (x1,y1) (x2,y2) =
    match compare x1 x2 with
    | 0 -> compare y1 y2
    | n -> n
end

module CoordMap = Map.Make(Coord)

type board = cell CoordMap.t

type shot_result =
  | S_Miss
  | S_Hit of ship_kind
  | S_Sunk of ship_kind

type player_state = {
  own_board : board;
  tracking_board : board;
  ships : ship list;
}

let grid_size = 10
