open Battleship_types
open Battleship_helper


let generate_ship_coordinates (start_coordinate: Battleship_types.coordinate) (ship_type: Battleship_types.ship_type) (input_orientation: Battleship_types.ship_orientation) : Battleship_types.coordinate list =
  let size = ship_size ship_type in
  let rec aux coord acc n =
    if n = 0 then List.rev acc
    else
      let next_coordinate =
        match input_orientation with
        | Horizontal -> { x_coordinate = coord.x_coordinate + 1; y_coordinate = coord.y_coordinate }
        | Vertical -> { x_coordinate = coord.x_coordinate; y_coordinate = coord.y_coordinate + 1 }
      in
      aux next_coordinate (coord :: acc) (n - 1)
  in
  aux start_coordinate [] size

let is_ship_within_bounds (coordinate_list: Battleship_types.coordinate list) (board: Battleship_types.board) : bool =
  List.for_all (fun coord ->
    coord.x_coordinate >= 1 && coord.x_coordinate <= board.board_size &&
    coord.y_coordinate >= 1 && coord.y_coordinate <= board.board_size
  ) coordinate_list

let does_ship_overlap (coordinate_list: Battleship_types.coordinate list) (board: Battleship_types.board) : bool =
  List.exists (fun ship ->
    List.exists (fun coord -> ship_contains_coordinate ship coord) coordinate_list
  ) board.ships

let is_ship_coordinate_valid (start_coordinate: Battleship_types.coordinate) (ship_type: Battleship_types.ship_type) (input_orientation: Battleship_types.ship_orientation) (board: Battleship_types.board) : bool =
  let ship_coords = generate_ship_coordinates start_coordinate ship_type input_orientation in
  is_ship_within_bounds ship_coords board && not (does_ship_overlap ship_coords board)

let place_ship_on_board (start_coordinate: Battleship_types.coordinate) (ship_type: Battleship_types.ship_type) (input_orientation: Battleship_types.ship_orientation) (board: Battleship_types.board) : Battleship_types.board * string =
  if not (is_ship_coordinate_valid start_coordinate ship_type input_orientation board) then
    (board, "Invalid ship placement: out of bounds or overlaps existing ship")
  else
    let ship_coords = generate_ship_coordinates start_coordinate ship_type input_orientation in
    let new_ship = {
      battleship_type = ship_type;
      orientation = input_orientation;
      coordinates = ship_coords;
      hits = [];
    } in
    let updated_board_cells = List.map (fun cell ->
      if coord_in_list cell.coordinate ship_coords then
        { coordinate = cell.coordinate; cell_type = ShipPart ship_type }
      else
        cell
    ) board.battleship_board in
    let new_board = { board_size = board.board_size; battleship_board = updated_board_cells; ships = new_ship :: board.ships } in
    (new_board, "Ship placed successfully")

let auto_place_all_ships (board: Battleship_types.board) : Battleship_types.board =
  let ship_types = [Carrier; Battleship; Cruiser; Submarine; Destroyer] in
  let orientations = [Horizontal; Vertical] in
  let rec place_ships b ships_to_place =
    match ships_to_place with
    | [] -> b
    | ship_type :: rest ->
      let rec try_place b =
        let x = Random.int board.board_size + 1 in
        let y = Random.int board.board_size + 1 in
        let orientation = List.nth orientations (Random.int (List.length orientations)) in
        let start_coord = { x_coordinate = x; y_coordinate = y } in
        if is_ship_coordinate_valid start_coord ship_type orientation b then
          let (new_board, msg) = place_ship_on_board start_coord ship_type orientation b in
            match msg with
            | "Ship placed successfully" -> new_board
            | _ -> try_place b
        else
          try_place b
      in
      let new_board = try_place b in
      place_ships new_board rest
  in
  place_ships board ship_types