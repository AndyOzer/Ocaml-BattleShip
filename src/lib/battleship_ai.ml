open Battleship_types
open Battleship_helper



(* easy: randomly select a coordinate that has not been targeted yet *)
let easy_next_fire_coordinate (board: Battleship_types.board) : Battleship_types.coordinate =
  let untargeted_cells = board.battleship_board |> List.filter (fun cell ->
    match cell.cell_type with
    | Empty | ShipPart _ -> true
    | Hit | Miss -> false
  ) in
  let random_index = Random.int (List.length untargeted_cells) in
  let target_cell = List.nth untargeted_cells random_index in
  target_cell.coordinate

(* medium: randomly select a coordinate that has not been targeted yet, if hit, fire adjacent cell until the ship is sunk *)
let medium_next_fire_coordinate (board: Battleship_types.board) : Battleship_types.coordinate =

  let untargeted_cells = board.battleship_board |> List.filter (fun cell ->
    match cell.cell_type with
    | Empty | ShipPart _ -> true
    | Hit | Miss -> false
  ) in

  let hit_cells = board.battleship_board |> List.filter (fun cell ->
    match cell.cell_type with
    | Hit -> true
    | _ -> false
  ) in

  let adjacent_untargeted_coords = hit_cells |> List.concat_map (fun hit_cell ->
    let x = hit_cell.coordinate.x_coordinate in
    let y = hit_cell.coordinate.y_coordinate in
    let potential_coords = [
      { x_coordinate = x + 1; y_coordinate = y };
      { x_coordinate = x - 1; y_coordinate = y };
      { x_coordinate = x; y_coordinate = y + 1 };
      { x_coordinate = x; y_coordinate = y - 1 };
    ] in

    let in_bounds_coords = List.filter (fun coord ->
      coord.x_coordinate >= 1 && coord.x_coordinate <= board.board_size &&
      coord.y_coordinate >= 1 && coord.y_coordinate <= board.board_size
    ) potential_coords in

    List.filter (fun coord ->
      List.exists (fun cell -> coord_equal cell.coordinate coord) untargeted_cells
    ) in_bounds_coords
  ) in

  match adjacent_untargeted_coords with
  | [] ->
      let random_index = Random.int (List.length untargeted_cells) in
      (List.nth untargeted_cells random_index).coordinate
  | _ ->
      let random_index = Random.int (List.length adjacent_untargeted_coords) in
      (List.nth adjacent_untargeted_coords random_index)

let optimal_next_fire_coordinate (board: Battleship_types.board) : Battleship_types.coordinate =
  let ship_cells = List.filter (fun cell ->
    match cell.cell_type with
    | ShipPart _ -> true
    | Empty | Hit | Miss -> false
  ) board.battleship_board in
  let random_index = Random.int (List.length ship_cells) in
  (List.nth ship_cells random_index).coordinate


module Coord = struct
  type t = int * int
  let compare = compare
end

module CoordMap = Map.Make(Coord)

type prob_map = int CoordMap.t

let update_heatmap_weight (coord : Coord.t) (delta : int) (map : prob_map) : prob_map =
  let update = function
    | None -> Some delta
    | Some v -> Some (v + delta)
  in
  CoordMap.update coord update map


let build_cell_map (board : Battleship_types.board) : board_cell_type CoordMap.t =
  let add_cell acc cell =
    let x = cell.coordinate.x_coordinate in
    let y = cell.coordinate.y_coordinate in
    CoordMap.add (x, y) cell.cell_type acc
  in
  board.battleship_board |> List.fold_left add_cell CoordMap.empty

let is_coordinate_invalid (size: int) (x: int) (y: int) : bool =
  x < 1 || x > size || y < 1 || y > size

let is_cell_already_shot (size: int) (cell_map: board_cell_type CoordMap.t) (x: int) (y: int) : bool =
  if is_coordinate_invalid size x y then true
  else
    match CoordMap.find_opt (x, y) cell_map with
    | Some Hit | Some Miss -> true
    | _ -> false

let alive_ship_coordinates (board : Battleship_types.board) : Coord.t list =
  let extract ship =
    List.map
      (fun c -> (c.x_coordinate, c.y_coordinate))
      ship.coordinates
  in
  List.concat_map extract board.ships

let is_ship_alive_hit (cell_map: board_cell_type CoordMap.t) (alive_coords: Coord.t list) (x: int) (y: int) : bool =
  if not (List.mem (x, y) alive_coords) then false
  else
    match CoordMap.find_opt (x, y) cell_map with
    | Some Hit -> true
    | _ -> false

let remaining_ship_types (board: Battleship_types.board) : Battleship_types.ship_type list =
  board.ships
  |> List.map (fun s -> s.battleship_type)
  |> List.sort_uniq compare


let return_all_coordinates (size: int) : Coord.t list =
  let rec iterate_rows y acc =
    if y > size then acc
    else
      let rec iterate_cols x row =
        if x > size then row
        else iterate_cols (x + 1) ((x, y) :: row)
      in
      iterate_rows (y + 1) (iterate_cols 1 [] @ acc)
  in
  iterate_rows 1 []


let ship_placement_heatmap_generation (map:prob_map) (placement: Coord.t list) : prob_map =
  placement |> List.fold_left (fun acc coord -> update_heatmap_weight coord 1 acc) map

let try_all_ship_placements (size: int) (is_blocked: int -> int -> bool) (ship_len: int) (x,y) : Coord.t list list =
  let offsets = List.init ship_len Fun.id in

  let fits_horizontally =
    x + ship_len - 1 <= size
    && List.for_all (fun i -> not (is_blocked (x + i) y)) offsets
  in

  let fits_vertically =
    y + ship_len - 1 <= size
    && List.for_all (fun i -> not (is_blocked x (y + i))) offsets
  in

  let placements = [] in
  let placements =
    if fits_horizontally then
      let coords = List.map (fun i -> (x + i, y)) offsets in
      coords :: placements
    else placements
  in
  let placements =
    if fits_vertically then
      let coords = List.map (fun i -> (x, y + i)) offsets in
      coords :: placements
    else placements
  in
  placements

let build_hunt_map (size: int) (ship_types: Battleship_types.ship_type list) (is_blocked: int -> int -> bool) : prob_map =
  let coords = return_all_coordinates size in

  ship_types |> List.fold_left (fun acc ship_type ->
    let ship_len = ship_size ship_type in
    List.fold_left (fun map start ->
      try_all_ship_placements size is_blocked ship_len start
      |> List.fold_left ship_placement_heatmap_generation map
    ) acc coords
  ) CoordMap.empty


let apply_target_bonus (size: int) (cell_map: board_cell_type CoordMap.t) (alive_coords: Coord.t list) (base_map: prob_map) : prob_map =
  let is_hit = is_ship_alive_hit cell_map alive_coords in
  let directions = [ (1,0); (-1,0); (0,1); (0,-1) ] in

  let apply_bonus_at acc (x, y) =
    if not (is_hit x y) then acc
    else
      List.fold_left
        (fun acc_map (dx, dy) ->
           let nx = x + dx in
           let ny = y + dy in
           if is_cell_already_shot size cell_map nx ny then acc_map
           else
             let bonus =
               match is_hit (x - dx) (y - dy) with
               | true  -> 15
               | false -> 10
             in
             update_heatmap_weight (nx, ny) bonus acc_map
        )
        acc
        directions
  in

  return_all_coordinates size
  |> List.fold_left apply_bonus_at base_map

let gen_prob_map (board : Battleship_types.board) : prob_map =
  let size = board.board_size in
  let cell_map = build_cell_map board in
  let alive_coords = alive_ship_coordinates board in

  let hunt_map =
    remaining_ship_types board
    |> (fun ship_types -> build_hunt_map size ship_types (is_cell_already_shot size cell_map))
  in

  apply_target_bonus size cell_map alive_coords hunt_map

let hard_next_fire_coordinate (board : Battleship_types.board) : Battleship_types.coordinate =

  let prob_map = gen_prob_map board in

  let best =
    CoordMap.fold (fun (x,y) value acc ->
      match acc with
      | None -> Some (value, [(x,y)])
      | Some (max_v, coords) ->
          if value > max_v then Some (value, [(x,y)])
          else if value = max_v then Some (max_v, (x,y)::coords)
          else acc
    ) prob_map None
  in

  match best with
  | None ->
    let (x,y) =
      let untargeted_cells = board.battleship_board |> List.filter (fun cell ->
        match cell.cell_type with
        | Empty | ShipPart _ -> true
        | Hit | Miss -> false
      ) in
      let random_index = Random.int (List.length untargeted_cells) in
      let target_cell = List.nth untargeted_cells random_index in
      (target_cell.coordinate.x_coordinate, target_cell.coordinate.y_coordinate)
    in
    { x_coordinate = x; y_coordinate = y }

  | Some (_, coords) ->
      let (x,y) =
        List.nth coords (Random.int (List.length coords))
      in
      { x_coordinate = x; y_coordinate = y }