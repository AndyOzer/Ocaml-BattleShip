open Battleship_types
open Battleship_helper

(* easy: randomly select a coordinate that has not been targeted yet *)
let easy_next_fire_coordinate (board: Battleship_types.board) : Battleship_types.coordinate =
  let untargeted_cells = List.filter (fun cell ->
    match cell.cell_type with
    | Empty | ShipPart _ -> true
    | Hit | Miss -> false
  ) board.battleship_board in
  let random_index = Random.int (List.length untargeted_cells) in
  let target_cell = List.nth untargeted_cells random_index in
  target_cell.coordinate

(* medium: randomly select a coordinate that has not been targeted yet, if hit, fire adjacent cell until the ship is sunk *)
let medium_next_fire_coordinate (board: Battleship_types.board) : Battleship_types.coordinate =
  let untargeted_cells = List.filter (fun cell ->
    match cell.cell_type with
    | Empty | ShipPart _ -> true
    | Hit | Miss -> false
  ) board.battleship_board in

  let hit_cells = List.filter (fun cell ->
    match cell.cell_type with
    | Hit -> true
    | _ -> false
  ) board.battleship_board in

  let adjacent_untargeted_coords = List.flatten (List.map (fun hit_cell ->
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
  ) hit_cells) in

  match adjacent_untargeted_coords with
  | [] ->
      let random_index = Random.int (List.length untargeted_cells) in
      (List.nth untargeted_cells random_index).coordinate
  | _ ->
      let random_index = Random.int (List.length adjacent_untargeted_coords) in
      (List.nth adjacent_untargeted_coords random_index)
