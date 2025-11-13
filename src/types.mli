type coord = int * int
(* A coordinate on the board *)

type orientation = Horizontal | Vertical
(* The orientation of a ship on the board *)

type ship_kind =
  | Carrier
  | Battleship
  | Cruiser
  | Submarine
  | Destroyer
(* The different kinds of ships *)

val ship_size : ship_kind -> int
(* Returns the size of the given ship kind *)

type ship = {
  kind : ship_kind;
  coords : coord list;
}
(* A ship with its kind and a list of occupied coordinates *)

type cell =
  | Empty (* Empty cell *)
  | Ship of ship_kind (* Ship cell but not hit *)
  | Miss (* Explored empty cell *)
  | Hit of ship_kind (* Hit cell with ship *)

module Coord : sig
  type t = coord
  val compare : t -> t -> int
end
(* A module for comparing coordinates *)

module CoordMap : Map.S with type key = Coord.t
(* A map from coordinates to values *)


type board = cell CoordMap.t
(* A board is a map from coordinates to cells *)

type shot_result =
  | S_Miss (* Missed shot *)
  | S_Hit of ship_kind (* Hit shot *)
  | S_Sunk of ship_kind (* Sunk shot *)

type player_state = {
  own_board : board;
  tracking_board : board;
  ships : ship list;
}
(* A player's state includes their own board, a tracking board, and a list of ships *)

val grid_size : int
